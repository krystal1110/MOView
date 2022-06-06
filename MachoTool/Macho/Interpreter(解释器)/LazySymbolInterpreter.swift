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
class LazySymbolInterpreter :BaseInterpreter {
    let numberOfPointers: Int
    let pointerSize: Int
    let startIndexInIndirectSymbolTable: Int
    let sectionType: SectionType

    init(wiht data: Data, is64Bit: Bool,
         machoProtocol: MachoProtocol,
         sectionVirtualAddress:UInt64,
         sectionType: SectionType,
         startIndexInIndirectSymbolTable: Int) {
        let pointerSize = is64Bit ? 8 : 4
        self.pointerSize = pointerSize
        numberOfPointers = data.count / pointerSize
        self.sectionType = sectionType
        self.startIndexInIndirectSymbolTable = startIndexInIndirectSymbolTable
        super.init(data, is64Bit: is64Bit, machoProtocol: machoProtocol, sectionVirtualAddress: sectionVirtualAddress)
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
        
        return LazySymbolStoreInfo(with: self.data, is64Bit:is64Bit, title: title, subTitle: subTitle, sectionVirtualAddress: sectionVirtualAddress,lazySymbolTableList: modelList)
    }
    
    
    func translationItem(at index:Int) -> ExplanationItem {
        let pointerRawData = DataTool.interception(with: data, from: index * pointerSize, length: pointerSize)
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
         
        return ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: data, start: index * pointerSize, pointerSize),
                               model: ExplanationModel(description: description,
                                                       explanation: pointerRawValue.hex,
                                                       
                                                       extraDescription: "Symbol Name of the Corresponding Indirect Symbol Table Entry",
                                                       extraExplanation: symbolName))
    }
    
 

 
}
