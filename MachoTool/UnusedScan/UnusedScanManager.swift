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
    
    init (with componts: [ComponentInfo] , parseSymbolTool: ParseSymbolTool){
        
        
        self.componts = componts
        self.parseSymbolTool = parseSymbolTool
        
        guard let _ = parseSymbolTool.symbolTableComponent?.symbolTableList else{
            return
        }
        
        /*
         OC相关 以及 Swift添加了 @objc
         **/
         
//        let referncesList  = (componts.filter{$0.componentTitle == SegmentType.DATA.rawValue &&
//            (
//             $0.componentSubTitle == DataSection.objc_nlclslist.rawValue)} as! [ReferencesCmponent]).flatMap{ $0.referencesPtrList}
//
//
        let xx = obtainAllClassList()
       let yy = obtainRefsClassList()
        
        
       print("---")
        
        
        
//        unusedOCFilter(allClassList, fiterPointer: referncesList)
        
        
        
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
       let textCompontList = componts.filter{$0.componentTitle == SegmentType.TEXT.rawValue && $0.componentSubTitle == TextSection.text.rawValue}

        if textCompontList.count == 1{
            textCompont = textCompontList[0] as! TextComponent
        }
        
//        let str = textCompont?.textInstructionPtr?[0].op_str
        
        
       
        
        
        print("----")
    }
    
    // 计算 函数中是否有 AccessFunc地址
    func calculateFuncRangeCallAccessFunc(symbolTableList: [SymbolTableModel], swiftTypesModel:SwiftNominalModel) -> Bool{
        
        var result = false
        
        for i in 0..<symbolTableList.count{
            var startValue: UInt64 = 0
            var endValue: UInt64 = 0
            if i == symbolTableList.count - 1 {
                startValue = symbolTableList[i].nValue
                endValue = 0
            }else{
                startValue = symbolTableList[i].nValue
                endValue = symbolTableList[i + 1].nValue
            }
           result =  findCallAccessFunc(swiftTypesModel.typeName, accessFunc: swiftTypesModel.accessorOffset, startVale: startValue, endValue: endValue)
            if result {return result}
        }
        return result
    }
    
    
    func findCallAccessFunc(_ typeName: String, accessFunc: UInt64 , startVale: UInt64, endValue: UInt64) -> Bool{
        
        let targetStr = String(format: "0x%llX",  accessFunc).localizedLowercase
        let targetHighStr = String(format: "0x%llX",  accessFunc & 0xFFFFFFFFFFFFF000).localizedLowercase
        let targetLowStr = String(format: "0x%llX",  accessFunc & 0x0000000000000fff).localizedLowercase
        let result = scanSELCallerWithAddress(targetStr: targetStr, targetHighStr: targetHighStr, targetLowStr: targetLowStr, begin: startVale, end: endValue)
        
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
        
        var endAddr:UInt64 = 0
        
        var asmStr:String = ""
        var high = false
        if (begin <  textAddr ){
            return false
        }
        
        let maxText = textAddr + (textCompont?.section?.info.size ?? 0)
        
        endAddr = min(maxText, end)
        
        var beginAddr = begin
        while (strcmp("ret",asmStr) != 0 && (beginAddr < end)){
            
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
                print("我命中了 \(dataStr) 与 \(targetStr)  index = \(index)")
                return true
            }else if (Utils.strStr(dataStr, targetHighStr) && Utils.strStr(asmStr, "adrp")){
                // 命中高位
                high = true
            }else if (Utils.strStr(dataStr, targetLowStr)) {
                // 命中低12位
                if high { return true }
            }
            // 4个字节4个字节读取
            beginAddr += 4
        }
        return false
    }
    
 
//    func unusedOCFilter(_ allPointer:[ReferencesPointer], fiterPointer:[ReferencesPointer]){
//        let result = allPointer.filter {  !fiterPointer.compactMap{$0.pointerValue}.contains($0.pointerValue)}
//        result.map{print($0.explanationItem?.model.extraExplanation)}
//    }
    
    
    
    /// 获取所有的类
    func obtainAllClassList() -> [String] {
        
        // 获取所有的类
        let classInfoList = (componts.filter{$0.componentTitle == SegmentType.DATA.rawValue && $0.componentSubTitle == DataSection.objc_classlist.rawValue} as! [ClassListCmponent]).flatMap{$0.classInfoList}
        
        
        var allClassList: [String] = []
        for i in classInfoList {
            if let className = i.className {
                allClassList.append(className)
            }
            if let superClaseeName = i.supclassName {
                allClassList.append(superClaseeName)
            }
        }
        return allClassList
    }
    
    
    /// 获取所有引用到的类
    func obtainRefsClassList() -> [String] {
         
        var refsClassList: [String] = []
        /* 获取 OC 相关的 直接可以从 __DATA,objc_classrefs 中获取  还需要获取Category中获取  已经load调用的函数 */
    
         
        
        // 获取非懒加载的cateory
        let classCategoryList = (componts.filter{$0.componentTitle == SegmentType.DATA.rawValue && $0.componentSubTitle == DataSection.objc_nlcatlist.rawValue} as! [ClassListCmponent]).flatMap{$0.classInfoList}
        
        for i in classCategoryList {
            if let className = i.className {
                refsClassList.append(className)
            }
        }
        
        
       // 获取 objc_classrefs当中的类
        let classRefsList = (componts.filter{$0.componentTitle == SegmentType.DATA.rawValue && $0.componentSubTitle == DataSection.objc_classrefs.rawValue} as! [ClassListCmponent]).flatMap{$0.classInfoList}
        
        for i in classRefsList {
            if let className = i.className {
                refsClassList.append(className)
            }
        }
        
        
   
        
        
        // 获取 Swift 相关的  通过 __DATA_Swif5types 中获取 Swift类的信息， 然后通过遍历__Text,text段的函数指令来 判断 是否调用 AccessFunc 函数
        
        // 获取swift类的信息
        let swiftTypesList = (componts.filter{$0.componentTitle == SegmentType.TEXT.rawValue && $0.componentSubTitle == TextSection.swift5types.rawValue} as! [SwiftTypesCmponent]).flatMap{$0.swiftTypesList}
       
        let symbolTableList  = parseSymbolTool.symbolTableComponent?.symbolTableList.sorted(by: { $0.nValue > $1.nValue})
        
        print("---")
        
        for i in swiftTypesList {
            if  calculateFuncRangeCallAccessFunc(symbolTableList: symbolTableList!, swiftTypesModel: i){
                refsClassList.append(i.typeName)
            }
        }
        
        print("---")
        
       
  
        
        
        return refsClassList
    }
    
    
}








