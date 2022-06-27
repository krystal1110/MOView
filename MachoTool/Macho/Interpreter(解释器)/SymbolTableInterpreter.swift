//
//  SymbolTableInterpreter.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/16.
//

import Foundation

class SymbolTableInterpreter {
    
    
//    // symbolTable解释器
//    func symbolTableInterpreter(with  data: Data ,is64Bit: Bool, symbolTableCommand: JYSymbolTableCommand) -> SymbolTableStoreInfo {
//        let symbolTableStartOffset = Int(symbolTableCommand.symbolTableOffset)
//        let numberOfEntries = Int(symbolTableCommand.numberOfSymbolTable)
//        let entrySize = is64Bit ? 16 : 12
//        let symbolTableData = DataTool.interception(with: data, from: symbolTableStartOffset, length: numberOfEntries * entrySize)
//
//        let symbolTableList =  MachoModel<JYSymbolTableEntryModel>.init().generateVessel(data: symbolTableData, is64Bit: is64Bit)
//
//        return SymbolTableStoreInfo(with: data, is64Bit: is64Bit, interpreter: self, title: "Symbol Table", subTitle: "__LINKEDIT", symbolTableList: symbolTableList)
//    }
//
//    // stringTable解释器
//    func stringTableInterpreter(with data: Data, is64Bit: Bool, SearchProtocol:SearchProtocol,  symbolTableCommand: JYSymbolTableCommand) -> StringTableStoreInfo{
//        let stringTableStartOffset = Int(symbolTableCommand.stringTableOffset)
//        let stringTableSize = Int(symbolTableCommand.stringTableSize)
//        let stringTableData = DataTool.interception(with: data, from: stringTableStartOffset, length: stringTableSize)
//
//        let interpreter = StringInterpreter(with: stringTableData,
//                                            is64Bit: is64Bit,
//                                            SearchProtocol:SearchProtocol ,
//                                            sectionVirtualAddress: 0)
//        let stringTableList = interpreter.generatePayload()
//
//        return StringTableStoreInfo(with: stringTableData,
//                                    is64Bit: is64Bit,
//                                    interpreter: interpreter,
//                                    title: "String Table",
//                                    subTitle: "__LINKEDIT",
//                                    sectionVirtualAddress: nil,
//                                    stringTableList: stringTableList)
//    }
}
