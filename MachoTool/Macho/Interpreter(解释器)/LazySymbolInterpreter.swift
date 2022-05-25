//
//  LazySymbolInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/24.
//

import Foundation


struct SymbolPointer{
    
}

/*
  LazySymobl 以及 No-LazySymbol 解析器
 **/
class LazySymbolInterpreter{
    
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
         startIndexInIndirectSymbolTable: Int ) {
        self.is64Bit = is64Bit
        self.data = data
        let pointerSize = is64Bit ? 8 : 4
        self.pointerSize = pointerSize
        self.machoProtocol = machoProtocol
        self.numberOfPointers = data.count / pointerSize
        self.sectionType = sectionType
        self.startIndexInIndirectSymbolTable = startIndexInIndirectSymbolTable
    }
    
//    let interpreter =  MachoModel<IndirectSymbolTableEntryModel>.init().generateVessel(data: indirectSymbolTableData, is64Bit: is64Bit)
    func generatePayload() -> [ExplanationItem]{
        var array:Array<ExplanationItem> = []
        for index in 0..<self.numberOfPointers {
           let item =  self.translationItem(at: index)
            array.append(item)
        }
        return array
    }
    
    
    func translationItem(at index:Int) -> ExplanationItem {
        let pointerRawData = data.interception(from: index * pointerSize, length: pointerSize).raw
        let pointerRawValue = is64Bit ? pointerRawData.UInt64 : UInt64(pointerRawData.UInt32)
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
