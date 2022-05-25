//
//  SymbolTableInterpreter.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/16.
//

import Foundation

class SymbolTableInterpreter: SeachStringTable {
    // symbolTable解释器
    func symbolTableInterpreter(with symbolTableCommand: JYSymbolTableCommand, is64Bit: Bool, data: DataSlice) -> SymbolTableInterpretInfo {
        let symbolTableStartOffset = Int(symbolTableCommand.symbolTableOffset)
        let numberOfEntries = Int(symbolTableCommand.numberOfSymbolTable)
        let entrySize = is64Bit ? 16 : 12
        let symbolTableData = data.interception(from: symbolTableStartOffset, length: numberOfEntries * entrySize)

        let interpreter = MachoModel<JYSymbolTableEntryModel>.init()

        let symbolTableList = interpreter.generateVessel(data: symbolTableData, is64Bit: is64Bit)

        return SymbolTableInterpretInfo(with: data, is64Bit: is64Bit, interpreter: self, symbolTableList: symbolTableList, title: "Symbol Table", subTitle: "__LINKEDIT")
    }

    // stringTable解释器
    func stringTableInterpreter(with symbolTableCommand: JYSymbolTableCommand, is64Bit: Bool, data: DataSlice) -> StringTableInterpretInfo {
        let stringTableStartOffset = Int(symbolTableCommand.stringTableOffset)
        let stringTableSize = Int(symbolTableCommand.stringTableSize)
        let stringTableData = data.interception(from: stringTableStartOffset, length: stringTableSize)

        let interpreter = StringInterpreter(with: stringTableData,
                                            is64Bit: is64Bit,
                                            sectionVirtualAddress: 0,
                                            searchSouce: nil)
        let stringTableList = interpreter.generatePayload()

        return StringTableInterpretInfo(with: stringTableData,
                                        is64Bit: is64Bit,
                                        interpreter: interpreter,
                                        stringTableList: stringTableList,
                                        title: "String Table",
                                        subTitle: "__LINKEDIT")
    }
}
