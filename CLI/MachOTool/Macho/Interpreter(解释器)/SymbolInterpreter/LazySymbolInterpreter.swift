
//  LazySymbolInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/24.
//

import Foundation

struct SymbolPointer {}

/*
   用于解析懒加载符号表 lazy-symbol / nolazy-symbol
 **/

struct LazySymbolInterpreter: Interpreter {
    
    var dataSlice: Data
    
    var section: Section64?
    
    var searchProtocol: SearchProtocol
    
    let numberOfPointers: Int
    let pointerSize: Int = 8
    let startIndexInIndirectSymbolTable: Int
    let sectionType: SectionType?
    
    init(with  dataSlice: Data, section:Section64,  searchProtocol:SearchProtocol){
        self.dataSlice = dataSlice
        self.section = section
        self.searchProtocol = searchProtocol
        numberOfPointers = dataSlice.count / pointerSize
        startIndexInIndirectSymbolTable = Int(section.info.reserved1)
        
        let sectionTypeRawValue = section.info.flags & 0x000000FF
        self.sectionType = SectionType(rawValue: sectionTypeRawValue)
    }
 

    // 转换为 stroeInfo 存储信息
    func transitionData() -> [LazySymbolEntryModel] {
        let modelSize = 8
        let numberOfModels = dataSlice.count / modelSize
        var models: [LazySymbolEntryModel] = []
        for index in 0 ..< numberOfModels {
            let startIndex = index * modelSize
            let modelData = DataTool.interception(with: dataSlice, from: startIndex, length: modelSize)
            var model = LazySymbolEntryModel(with: modelData)
            model.explanationItem = translationItem(at: index)
            models.append(model)
        }
        return models
    }
    
    
    
    func translationItem(at index:Int) -> ExplanationItem {
        let pointerRawData = DataTool.interception(with: dataSlice, from: index * pointerSize, length: pointerSize)
        let pointerRawValue =   pointerRawData.UInt64
        let indirectSymbolTableIndex = index + startIndexInIndirectSymbolTable
        
        var symbolName: String?
        
        if let _symbolName = searchProtocol.searchInIndirectSymbolTableList(at: indirectSymbolTableIndex){
            symbolName = _symbolName
        }
        
        var description = "Pointer Raw Value"
        if sectionType == .S_LAZY_SYMBOL_POINTERS {
            description += " (Stub offset)"
        } else if sectionType == .S_NON_LAZY_SYMBOL_POINTERS {
            description += " (To be fixed by dyld)"
        }
         
        return ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: dataSlice, start: index * pointerSize, pointerSize),
                               model: ExplanationModel(description: description,
                                                       explanation: pointerRawValue.hex,
                                                       
                                                       extraDescription: "Symbol Name of the Corresponding Indirect Symbol Table Entry",
                                                       extraExplanation: symbolName))
    }
    
 
    
 

 
}
