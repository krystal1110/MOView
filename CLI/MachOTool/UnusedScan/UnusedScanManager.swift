//
//  UnusedScanManager.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/2.
//

import Foundation


enum UnusedScanType: String {
    case TEXT = "__objc_classlist"
    case DATA = "__objc_classrefs"
    case PAGEZERO = "__PAGEZERO"
    case LINKEDIT = "__LINKEDIT"
}





class UnusedScanManager {
    
    //    var macho:Macho
    var componts: [ComponentInfo] = []
    
    var textCompont : TextModule?
    
    var parseSymbolTool: ParseSymbolTool
    
    var sectionFlagsDic: Dictionary<Int,Int>
    
    /// 用于记录
    var cacheMetaDic:Dictionary<String,UInt64> = [:]
    
    var refsClassSet:Set<String> = []
 
    
    
    init (with componts: [ComponentInfo] , parseSymbolTool: ParseSymbolTool , sectionFlagsDic: Dictionary<Int,Int> ){
        
        
        self.sectionFlagsDic = sectionFlagsDic
        self.componts = componts
        self.parseSymbolTool = parseSymbolTool
        
        guard let _ = parseSymbolTool.symbolTableComponent?.symbolTableList else{
            return
        }
        
        /*
         OC相关 以及 Swift添加了 @objc
         **/
        
        let textCompontList = componts.filter{$0.componentTitle == SegmentType.TEXT.rawValue && $0.componentSubTitle == TextSection.text.rawValue}
        
        if textCompontList.count == 1{
            textCompont = textCompontList[0] as! TextModule
        }
        
        
    }
    
    /// 扫描无用类
    func scanUselessClasses() {
        obtainRefsClassSet()
        let allClassSet = obtainAllClassSet()
        
        let uselessClassList =  allClassSet.subtracting(refsClassSet)
        print("检测无用类 共有 \(uselessClassList.count)")
        
    }
    
    
    /// 获取__DATA,class_list 中的数据
    private func obtainAllClassSet() -> Set<String> {
        
        let allClassSet: Set<String> = []
        
        // 获取所有的类
        let componts = (componts.filter{$0.componentTitle == SegmentType.DATA.rawValue && $0.componentSubTitle == DataSection.objc_classlist.rawValue} as! [ClassListModule])
        
        // 枚举等用到的
        if  let refsSet = componts.first?.classRefSet  {
            refsClassSet = refsClassSet.union(refsSet)
        }
        
        guard  let set = componts.first?.classNameSet else {
            return allClassSet
        }
        
        return set
    }
    
    
    /// 获取所有引用到的类
    private func obtainRefsClassSet()  {
         
        /* 获取 OC 相关的 直接可以从 __DATA,objc_classrefs 中获取  还需要获取Category中获取  已经load调用的函数 */
        
        // 获取 nlclslist当中的类 16
        let nlclslist = (componts.filter{$0.componentTitle == SegmentType.DATA.rawValue && $0.componentSubTitle == DataSection.objc_nlclslist.rawValue} as! [ClassListModule]).flatMap{$0.pointers}
        
        for i in nlclslist {
            if let className = i.className {
                refsClassSet.insert(className)
            }
        }
        
        // 获取 objc_classrefs当中的类   1302
        let classRefsList = (componts.filter{$0.componentTitle == SegmentType.DATA.rawValue && $0.componentSubTitle == DataSection.objc_classrefs.rawValue} as! [ClassListModule]).flatMap{$0.pointers}
        
        for i in classRefsList {
            if let className = i.className {
                if className.count != 0 {
                    refsClassSet.insert(className)
                }
            }
        }
        
        
        
        // 获取非懒加载的cateory
        let classCategoryList = (componts.filter{$0.componentTitle == SegmentType.DATA.rawValue && $0.componentSubTitle == DataSection.objc_nlcatlist.rawValue} as! [ClassListModule]).flatMap{$0.pointers}
        
        for i in classCategoryList {
            if let className = i.className {
                refsClassSet.insert(className)
            }
        }
        
        
        
        // 获取__DATA,Cstring -> 解决 NSClassFromString 的导入
        let cStringlist = (componts.filter{$0.componentTitle == SegmentType.DATA.rawValue && $0.componentSubTitle == DataSection.cfstring.rawValue} as! [CFStringModule]).flatMap{$0.pointers}
        
        for i in cStringlist {
            refsClassSet.insert(i.stringName)
            
        }
        
        
        
        // 获取 Swift 相关的  通过 __DATA_Swif5types 中获取 Swift类的信息， 然后通过遍历__Text,text段的函数指令来 判断 是否调用 AccessFunc 函数
        
        let swiftRefsSet = (componts.filter{$0.componentTitle == SegmentType.TEXT.rawValue && $0.componentSubTitle == TextSection.swift5types.rawValue} as! [SwiftTypesModule]).flatMap{$0.swiftRefsSet}
        
        for i in swiftRefsSet{
            refsClassSet.insert(i)
        }
        
        let accessFuncList  = (componts.filter{$0.componentTitle == SegmentType.TEXT.rawValue && $0.componentSubTitle == TextSection.swift5types.rawValue} as! [SwiftTypesModule]).flatMap{$0.accessFuncDic}
        let symbolTableList  =  sortedSymbolList()
        
        let lock:NSLock = NSLock.init()
        print("Begin to start a DispatchApply")
//        DispatchQueue.global(qos: .userInteractive).async {
            DispatchQueue.concurrentPerform(iterations: accessFuncList.count) { (index) in
//        for index in 0..<accessFuncList.count {
                    autoreleasepool {
                        let i = accessFuncList[index]
                        let accessFunc = i.value
                        print("我正在执行 == \(index) thread == \(Thread.current)")
                        if self.calculateFuncRangeCallAccessFunc(symbolTableList: symbolTableList, accessFunc: accessFunc, symbolName: i.key){
                            lock.lock()
                            self.refsClassSet.insert(i.key)
                            lock.unlock()
                        }
                    }
//            }
        }
        print("Iteration have completed.")
    }
    
    
    
    
    // 计算 函数中是否有 AccessFunc地址
    private func calculateFuncRangeCallAccessFunc(symbolTableList: [SymbolRange], accessFunc:UInt64, symbolName:String) -> Bool {
        
        
        for j in 0..<symbolTableList.count {
            let item = symbolTableList[j]
            var startValue: UInt64 = 0
            var endValue: UInt64 = 0
            if j == symbolTableList.count - 1 {
                startValue = symbolTableList[j].nValue
                endValue = 0
            }else{
                startValue = symbolTableList[j].nValue
                endValue = symbolTableList[j + 1].nValue
            }
            
            if symbolName == "" || item.symbolName.hasPrefix(symbolName)  {
                // 过滤掉  symbol当中调用自己的类
                continue;
            }
            
            let targetStr = String(format: "0x%llX",  accessFunc).lowercased()
            let targetHighStr = String(format: "0x%llX",  accessFunc & 0xFFFFFFFFFFFFF000).lowercased()
            let targetLowStr = String(format: "0x%llX",  accessFunc & 0x0000000000000fff).lowercased()

            let find =  scanSELCallerWithAddress(targetStr: targetStr, targetHighStr: targetHighStr, targetLowStr: targetLowStr, begin: startValue, end: endValue)
            if find {
                return true
            }
        }
        return false
    }
    
    
    /*
     扫描函数代码中是否包含有 AccessFunc 的地址，如果有则代表有用到这个类，如果没有则代表没有用到
     注意：会有一种特殊情况为 Swift访问并不是通过AccessFunc，而是直接访问类的地址，这种情况一般会在符号表中存在demangling cache variable for type metadata for开头的符号
     begin 代表符号地址开始
     end   代表符号地址结束
     **/
    private func scanSELCallerWithAddress(targetStr: String, targetHighStr: String, targetLowStr: String, begin: UInt64, end: UInt64) -> Bool {
         
        guard let  section =  textCompont?.section else{
            return false
        }
        let textAddr:UInt64 = section.info.addr
        
        var endAddr:UInt64 = end
        
        var asmStr:String = ""
        var high = false
        
        
        if (begin <  textAddr ){
            return false
        }
        let maxText = textAddr + (section.info.size)
        endAddr = min(maxText, end)
        var beginAddr = begin
        guard let textInstructionPtr = textCompont?.csInsnPointer else{
            return false
        }
        repeat {
            let index = (beginAddr - textAddr) / 4
            var op_str   = textInstructionPtr[Int(index)].op_str
            var mnemonic = textInstructionPtr[Int(index)].mnemonic
            let dataStr =  Utils.readCharToString(&op_str)
            asmStr =  Utils.readCharToString(&mnemonic)
            
            if (strcmp(".byte", asmStr) == 0){
                return false
            }
            if (dataStr.contains(targetStr)){
                // 直接命中
                return true
            }else if (dataStr.contains(targetHighStr) && asmStr.contains("adrp")){
                // 命中高位
                high = true
                 
            }else if (dataStr.contains(targetLowStr)) {
                // 命中低12位
                if high {
                    return true
                }
            }
            // 4个字节4个字节读取
            beginAddr += 4
        }while (strcmp("ret",asmStr) != 0 && (beginAddr < endAddr))
        
        return false
    }
    
    
    
    
    /// 排序以及过滤 Symbol Table
    private func sortedSymbolList() -> [SymbolRange]{
        
        
        // 这里用字典实现 因为用数组后面去重 会很影响效率
        var symbolDic : Dictionary<String,UInt64> = [:]
        var symbolList : [SymbolRange] = []
        
        
        
        for i in 0..<parseSymbolTool.symbolTableComponent!.symbolTableList.count{
            var item = parseSymbolTool.symbolTableComponent!.symbolTableList[i]
            let flags =  sectionFlagsWithIndex(Int(item.nSect))
            if ((flags & 0x80000000 | 0x00000400) == (0x80000000 | 0x00000400)) {
                if let symbolName =  item.findSymbolName() {
                    
                    item.symbolName = symbolName
                    if symbolName == "__mh_execute_header"{
                        continue
                    }
                    // 过滤掉OC的 - + 方法
                    if   (symbolName.hasPrefix("-") || symbolName.hasPrefix("+") ){
                        continue
                    }
                    symbolDic.updateValue(item.nValue, forKey: item.symbolName)
                }
            }else{
                // 过滤掉不等于的
                if var symbolName =  item.findSymbolName() {
                    
                    if symbolName.hasPrefix("demangling cache variable for type metadata for "){
                        symbolName = symbolName.replacingOccurrences(of: "demangling cache variable for type metadata for " , with: "")
                        let tmp = symbolName.components(separatedBy: "<")
                        if let typeName = tmp.first  {
                            if item.nValue > 0 {
                                cacheMetaDic.updateValue(item.nValue, forKey: typeName)
                            }
                        }
                    }
                    
                }
            }
        }
        
        // 过滤掉重复元素以及排序
        for (key, value) in symbolDic {
            let model = SymbolRange(nValue: value,symbolName: key)
            symbolList.append(model)
        }
        let sortSymList =  symbolList.sorted(by: { $0.nValue < $1.nValue})
        return sortSymList
    }
    
    
    private func sectionFlagsWithIndex(_ index:Int) -> Int{
        return  sectionFlagsDic[index] ?? 0
    }
    
    
}





