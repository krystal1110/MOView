
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
//        let _ = DataTool.interception(with: dataSlice, from: index * pointerSize, length: pointerSize)
        let indirectSymbolTableIndex = index + startIndexInIndirectSymbolTable
        
        var symbolName: String?
        
        if let _symbolName = searchProtocol.searchInIndirectSymbolTableList(at: indirectSymbolTableIndex){
            symbolName = _symbolName
        }
        let dataRange = DataTool.absoluteRange(with: dataSlice, start: index * pointerSize, pointerSize)
        return ExplanationItem(sourceDataRange: dataRange,
                               model: ExplanationModel(description: "Offset",
                                                       explanation: dataRange.startIndex.hex,
                                                       extraDescription: "Symbol Name",
                                                       extraExplanation: symbolName))
    }

}
