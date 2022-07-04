//
//  CategoryInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/30.
//

import Foundation


struct Category64 {
    let name: UInt64
    let cls: UInt64
    let instanceMethods: UInt64
    let classMethods: UInt64
    let instanceProperties: UInt64
}


struct CategoryInterpreter: Interpreter {
    
    var dataSlice: Data
    
    var section: Section64?
    
    var searchProtocol: SearchProtocol
    
    let pointerLength: Int = 8
    
    init(with  dataSlice: Data, section:Section64,  searchProtocol:SearchProtocol){
        self.dataSlice = dataSlice
        self.section = section
        self.searchProtocol = searchProtocol
    }
    
    
    
    
    
    func transitionData() -> [ClassInfo]  {
         
        let rawData = self.dataSlice
        guard rawData.count % pointerLength == 0 else { fatalError() /* section of type S_LITERAL_POINTERS should be in align of 8 (bytes) */  }
        var classInfoList: [ClassInfo] = []
        let numberOfPointers = rawData.count / 8
        
        for index in 0..<numberOfPointers {
            let relativeDataOffset = index * pointerLength

            // 过滤掉系统的 Category
            if let classInfo = loadCategoryList(relativeDataOffset) {
                classInfoList.append(classInfo)
            }
            
        }
        return classInfoList
    }
    
    
    func translationItem(with pointer:ReferencesPointer) -> ExplanationItem {
        #warning("TODO")
        var symbolName = ""
//        self.searchProtocol.searchString(by: pointer.pointerValue)
        
//        if (symbolName == nil){
//            symbolName = self.searchProtocol.searchStringInSymbolTable(by: pointer.pointerValue)
//        }
        
        return ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: dataSlice, start: pointer.relativeDataOffset, self.pointerLength),
                               model: ExplanationModel(description: "Pointer Value (Virtual Address)",
                                                       explanation: pointer.pointerValue.hex,
                                                       
                                                       extraDescription: "Referenced String Symbol",
                                                       extraExplanation: symbolName))
    }
    
    
    
    func loadCategoryList(_ relativeDataOffset:Int) -> ClassInfo?{
       
        var classNameStr: String?
        
        let data =  dataSlice.select(from: relativeDataOffset, length: pointerLength)
         
        
        
        let machoData = searchProtocol.getMachoData()
         
        let catOffset =  searchProtocol.getOffsetFromVmAddress(data.UInt64)
       
        let targetCategory =  machoData.extract(Category64.self, offset: catOffset.toInt)
        
        //例如 UIViewController(MyCategory) +load ，cls 为 0 ，所以排除掉
        if (targetCategory.cls == 0) {
            return nil
        }

        let classOffset =  searchProtocol.getOffsetFromVmAddress(targetCategory.cls)
       
        let targetClass =  machoData.extract(Class64.self, offset: classOffset.toInt)
        
        var targetClassInfoOffset =  searchProtocol.getOffsetFromVmAddress(targetClass.data)
        
        // Remove the decimal
        targetClassInfoOffset = (targetClassInfoOffset / 8) * 8
        
        let targetClassInfo =  machoData.extract(Class64Info.self, offset: targetClassInfoOffset.toInt)
        
        let classNameOffset =  searchProtocol.getOffsetFromVmAddress(targetClassInfo.name)
        
        if let className =  machoData.readCString(from: classNameOffset.toInt){
            classNameStr = className
        }
           
        return ClassInfo(relativeDataOffset, pointerValue: data.UInt64,class64: targetClass, class64Info: targetClassInfo, className: classNameStr)
    }
}
