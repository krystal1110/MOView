//
//  LazySymbolInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/24.
//

import Foundation

struct SymbolPointer {}

/*
  LazySymobl 以及 No-LazySymbol 解析器
 **/
class LazySymbolInterpreter {
    let data: DataSlice
    let numberOfPointers: Int
    let machoProtocol: MachoProtocol
    let pointerSize: Int
    let is64Bit: Bool
    let startIndexInIndirectSymbolTable: Int
    let sectionType: SectionType

    init(wiht data: DataSlice, is64Bit: Bool,
         machoProtocol: MachoProtocol,
         sectionType: SectionType,
         startIndexInIndirectSymbolTable: Int) {
        self.is64Bit = is64Bit
        self.data = data
        let pointerSize = is64Bit ? 8 : 4
        self.pointerSize = pointerSize
        self.machoProtocol = machoProtocol
        numberOfPointers = data.count / pointerSize
        self.sectionType = sectionType
        self.startIndexInIndirectSymbolTable = startIndexInIndirectSymbolTable
        
    }

    // 转换为 stroeInfo 存储信息
    func transitionStoreInfo(title:String , subTitle:String ) -> LazySymbolStoreInfo {
        
        var modelList = MachoModel<LazySymbolEntryModel>.init().generateVessel(data: self.data, is64Bit: is64Bit)
        
        // 在外层转换 因为Model是固定生成的 外层转换后塞进去
        for index in 0..<modelList.count {
            var model = modelList[index]
            let item = translationItem(at: index)
            model.explanationItem = item
            modelList[index] = model
        }
        
        return LazySymbolStoreInfo(with: self.data, is64Bit:is64Bit, lazySymbolTableList: modelList, title: title, subTitle: subTitle)
    }
    
    
    func translationItem(at index:Int) -> ExplanationItem {
        let pointerRawData = self.data.interception(from: index * pointerSize, length: pointerSize).raw
        let pointerRawValue = self.is64Bit ? pointerRawData.UInt64 : UInt64(pointerRawData.UInt32)
        let indirectSymbolTableIndex = index + startIndexInIndirectSymbolTable
        
        var symbolName: String?
        
        if let indirectSymbolTableEntry = machoProtocol.indexInIndirectSymbolTable(at: indirectSymbolTableIndex),
           
           let symbolTableEntry = machoProtocol.indexInSymbolTable(at: indirectSymbolTableEntry.symbolTableIndex),
           let _symbolName = machoProtocol.stringInStringTable(at: Int(symbolTableEntry.indexInStringTable)) {
           symbolName = _symbolName
        }
        
        var description = "Pointer Raw Value"
        if sectionType == .S_LAZY_SYMBOL_POINTERS {
            description += " (Stub offset)"
        } else if sectionType == .S_NON_LAZY_SYMBOL_POINTERS {
            description += " (To be fixed by dyld)"
        }
        
        return ExplanationItem(sourceDataRange: data.absoluteRange(index * pointerSize, pointerSize),
                               model: ExplanationModel(description: description,
                                                       explanation: pointerRawValue.hex,
                                                       
                                                       extraDescription: "Symbol Name of the Corresponding Indirect Symbol Table Entry",
                                                       extraExplanation: symbolName))
    }
    
 

 
}
