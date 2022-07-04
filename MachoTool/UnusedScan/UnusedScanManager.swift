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
    
    var textCompont : TextComponent?
    
    var parseSymbolTool: ParseSymbolTool
    
    var sectionFlagsDic: Dictionary<Int,Int>
    
    var cacheDic:Dictionary<String,UInt64> = [:]
    
    var refsClassSet:Set<String> = []
    
    func elapsedTime(){
        
    }
    
    
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
            textCompont = textCompontList[0] as! TextComponent
        }
        
       obtainRefsClassSet()
       
        let allClassSet = obtainAllClassSet()
        
        
        
        let uselessClassList = allClassSet.filter {!refsClassSet.compactMap{$0}.contains($0)}
        
        print("---")
        
//        let uselessClassSet = allClassSet.subtracting(refsClassSet)
        
//        let singleDigitPrimeSet = allClassSet.symmetricDifference(refsClassSet)

//        let endTimeStamp = Date().timeStamp
        
 
 

     
 
//        var  endformatter = DateFormatter()
//        endformatter.dateFormat = "yyyy-MM-dd"
//        endformatter.timeZone = TimeZone.init(secondsFromGMT: 0)
//        var enddates = formatter.string(from: Date())
//
//
//        Date().twoTimeDiffDay(fromTime: dates, endTime: enddates)
        
        print("---")
  
        /*
         检测 Swift 作为属性
         解析 Swift5Types 拿到对应的 AccessFunc，AccessFunc可以拿到对应的metadata，然后调用函数
         扫描函数代码中是否包含有 AccessFunc 的地址，如果有则代表有用到这个类，如果没有则代表没有用到
         注意：会有一种特殊情况为 Swift访问并不是通过AccessFunc，而是直接访问类的地址，这种情况一般会在符号表中存在demangling cache variable for type metadata for开头的符号
         begin 代表符号地址开始
         end   代表符号地址结束
         **/
        //        let compont = componts.filter{$0.componentTitle == SegmentType.TEXT.rawValue && $0.componentSubTitle == TextSection.swift5types.rawValue}
        //
        //
        
        
        //        let str = textCompont?.textInstructionPtr?[0].op_str
        
        
        
        
        
        print("----")
    }
    
    // 计算 函数中是否有 AccessFunc地址
    func calculateFuncRangeCallAccessFunc(symbolTableList: [SymbolRange], swiftTypesModel:SwiftNominalModel ,  refsClassSet:inout Set<String>){
        
        var refsList:Set<String> = []
        
        //获取系统存在的全局队列
        let queue = DispatchQueue.global(qos: .default)
        
        let lock:NSLock = NSLock.init()
        
        //定义一个异步步代码块
        queue.async {
            
            //通过concurrentPerform，循环变量数组
            DispatchQueue.concurrentPerform(iterations: symbolTableList.count) {(i) -> Void in
                
                let item = symbolTableList[i]
                var startValue: UInt64 = 0
                var endValue: UInt64 = 0
                if i == symbolTableList.count - 1 {
                    startValue = symbolTableList[i].nValue
                    endValue = 0
                }else{
                    startValue = symbolTableList[i].nValue
                    endValue = symbolTableList[i + 1].nValue
                }
                
                 if item.symbolName == "" || item.symbolName.hasPrefix(swiftTypesModel.className)  {
                    // 过滤掉  symbol当中调用自己的类
                }else{
                    if self.findCallAccessFunc(swiftTypesModel.className, accessFunc: swiftTypesModel.accessorOffset, startVale: startValue, endValue: endValue){
                        lock.lock()
                        refsList.insert(swiftTypesModel.className)
                        lock.unlock()
                    }
                }
                
 
                
                
            }
        }
        
        if refsList.count>0{
         let _ = refsList.compactMap{ refsClassSet.insert($0)}
        }
       
        
    }
    
    
    func findCallAccessFunc(_ className: String, accessFunc: UInt64 , startVale: UInt64, endValue: UInt64) -> Bool{
        
        let targetStr = String(format: "0x%llX",  accessFunc).localizedLowercase
        let targetHighStr = String(format: "0x%llX",  accessFunc & 0xFFFFFFFFFFFFF000).localizedLowercase
        let targetLowStr = String(format: "0x%llX",  accessFunc & 0x0000000000000fff).localizedLowercase
        
        
        
        let result = scanSELCallerWithAddress(targetStr: targetStr, targetHighStr: targetHighStr, targetLowStr: targetLowStr, begin: startVale, end: endValue)
        
        if result {
            
            return result
            
        }
        
        return result
    }
    
    
    
    
    
    /*
     扫描函数代码中是否包含有 AccessFunc 的地址，如果有则代表有用到这个类，如果没有则代表没有用到
     注意：会有一种特殊情况为 Swift访问并不是通过AccessFunc，而是直接访问类的地址，这种情况一般会在符号表中存在demangling cache variable for type metadata for开头的符号
     begin 代表符号地址开始
     end   代表符号地址结束
     **/
    func scanSELCallerWithAddress(targetStr: String, targetHighStr: String, targetLowStr: String, begin: UInt64, end: UInt64) -> Bool {
        
        
        let textAddr:UInt64 = textCompont?.section?.info.addr ?? 0
        
        var endAddr:UInt64 = end
        
        var asmStr:String = ""
        var high = false
        if (begin <  textAddr ){
            return false
        }
        
        let maxText = textAddr + (textCompont?.section?.info.size ?? 0)
        
        endAddr = min(maxText, end)
        
        var beginAddr = begin
        
        while (strcmp("ret",asmStr) != 0 && (beginAddr < endAddr)){
            
            let index = (beginAddr - textAddr) / 4
            
            var op_str = textCompont?.textInstructionPtr?[Int(index)].op_str
            var mnemonic = textCompont?.textInstructionPtr?[Int(index)].mnemonic
            
            let dataStr =  Utils.readCharToString(&op_str)
            
            asmStr =  Utils.readCharToString(&mnemonic)
            
            if (strcmp(".byte", asmStr) == 0){
                return false
            }
            
            if (Utils.strStr(dataStr, targetStr)){
                // 直接命中
                
                return true
            }else if (Utils.strStr(dataStr, targetHighStr) && Utils.strStr(asmStr, "adrp")){
                // 命中高位
                high = true
            }else if (Utils.strStr(dataStr, targetLowStr)) {
                // 命中低12位
                if high {
                    return true
                    
                }
            }
            // 4个字节4个字节读取
            beginAddr += 4
        }
        return false
    }
    
    
    
    
    
    
    /// 获取所有的类
    func obtainAllClassSet() -> Set<String> {
        
        let allClassSet: Set<String> = []
        
        // 获取所有的类
        let componts = (componts.filter{$0.componentTitle == SegmentType.DATA.rawValue && $0.componentSubTitle == DataSection.objc_classlist.rawValue} as! [ClassListCmponent])
        
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
    func obtainRefsClassSet() {
//        var refsClassSet = Set<String>()
        /* 获取 OC 相关的 直接可以从 __DATA,objc_classrefs 中获取  还需要获取Category中获取  已经load调用的函数 */
        
        // 获取 nlclslist当中的类 16
        let nlclslist = (componts.filter{$0.componentTitle == SegmentType.DATA.rawValue && $0.componentSubTitle == DataSection.objc_nlclslist.rawValue} as! [ClassListCmponent]).flatMap{$0.classInfoList}
        
        for i in nlclslist {
            if let className = i.className {
                refsClassSet.insert(className)
            }
        }
        
        // 获取 objc_classrefs当中的类   1302
        let classRefsList = (componts.filter{$0.componentTitle == SegmentType.DATA.rawValue && $0.componentSubTitle == DataSection.objc_classrefs.rawValue} as! [ClassListCmponent]).flatMap{$0.classInfoList}
        
        for i in classRefsList {
            if let className = i.className {
                if className.count != 0 {
                    refsClassSet.insert(className)
                }
            }
        }
        
         
        
        // 获取非懒加载的cateory
        let classCategoryList = (componts.filter{$0.componentTitle == SegmentType.DATA.rawValue && $0.componentSubTitle == DataSection.objc_nlcatlist.rawValue} as! [ClassListCmponent]).flatMap{$0.classInfoList}
        
        for i in classCategoryList {
            if let className = i.className {
                refsClassSet.insert(className)
            }
        }
        
        
 
        print("---")
        
 
        
        // 获取__DATA,Cstring -> 解决 NSClassFromString 的导入
        let cStringlist = (componts.filter{$0.componentTitle == SegmentType.DATA.rawValue && $0.componentSubTitle == DataSection.cfstring.rawValue} as! [CFStringComponent]).flatMap{$0.objcCFStringList}
        
        for i in cStringlist {
            refsClassSet.insert(i.stringName)
             
        }
        
        print("---")
        
        // 获取 Swift 相关的  通过 __DATA_Swif5types 中获取 Swift类的信息， 然后通过遍历__Text,text段的函数指令来 判断 是否调用 AccessFunc 函数
        
        // 获取swift类的信息
        let swiftTypesList = (componts.filter{$0.componentTitle == SegmentType.TEXT.rawValue && $0.componentSubTitle == TextSection.swift5types.rawValue} as! [SwiftTypesCmponent]).flatMap{$0.swiftTypesList}

         
//        var refsClassList = refsClassSet.map { $0 }
        
        
        let symbolTableList  =  sortedSymbolList()
        for i in swiftTypesList {
            calculateFuncRangeCallAccessFunc(symbolTableList: symbolTableList, swiftTypesModel: i , refsClassSet: &refsClassSet)
        }
        
        
        
        
    }
    
    
    
    
    func sortedSymbolList() -> [SymbolRange]{
        
        
        // 这里用字典实现 因为用数组后面去重 会很影响效率
        var symbolDic : Dictionary<String,UInt64> = [:]
        var symbolList : [SymbolRange] = []
        
        
        
        for i in 0..<parseSymbolTool.symbolTableComponent!.symbolTableList.count{
            var item = parseSymbolTool.symbolTableComponent!.symbolTableList[i]
            let flags =  sectionFlagsWithIndex(Int(item.nSect))
            if ((flags & 0x80000000 | 0x00000400) == (0x80000000 | 0x00000400)) {
                if let symbolName =  item.findSymbolName() {
                    
                    
                    if symbolName ==  "demangling cache variable for type metadata for " {
                        cacheDic.updateValue(item.nValue, forKey: symbolName)
                    }
                    
                    item.symbolName = symbolName
                    if symbolName == "__mh_execute_header"{
                        continue
                    }
                    // 过滤掉OC的 - + 方法
                    if   (symbolName.hasPrefix("-") || symbolName.hasPrefix("+") ){
                        continue
                    }
                    //                    symbolList.append(item)
                    symbolDic.updateValue(item.nValue, forKey: item.symbolName)
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
    
    
    func sectionFlagsWithIndex(_ index:Int) -> Int{
        return  sectionFlagsDic[index] ?? 0
    }
    
    
}









extension Array {
    
    // 去重
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
}



extension Date {

/// 获取当前 秒级 时间戳 - 10位
var timeStamp : Int {
    let timeInterval: TimeInterval = self.timeIntervalSince1970
    let timeStamp = Int(timeInterval)
    return timeStamp
}

/// 获取当前 毫秒级 时间戳 - 13位
var milliStamp : String {
    let timeInterval: TimeInterval = self.timeIntervalSince1970
    let millisecond = CLongLong(round(timeInterval*1000))
    return "\(millisecond)"
}
    
    func twoTimeDiffDay(fromTime: Date, endTime: Date, calendar: Calendar = .current) -> Int {
  
       let formerTime = calendar.startOfDay(for: fromTime)
  
       let endTime = calendar.startOfDay(for: endTime)
  
       return calendar.dateComponents([.day], from: formerTime, to: endTime).day ?? 1000 // 默认一个比较大的值，就显示具体时间了
   
    }
 
}
 
