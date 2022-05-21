//
//  SymbolTableInterpreter.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/16.
//

import Foundation


class SymbolTableInterpreter: SeachStringTable{
    
    // symbolTable解释器
    func symbolTableInterpreter(with symbolTableCommand:JYSymbolTableCommand , is64Bit:Bool , data:DataSlice) -> SymbolTableInterpretModel {
        
        let symbolTableStartOffset = Int(symbolTableCommand.symbolTableOffset)
        let numberOfEntries = Int(symbolTableCommand.numberOfSymbolTable)
        let entrySize = is64Bit ? 16 : 12
        let symbolTableData = data.interception(from: symbolTableStartOffset, length: numberOfEntries * entrySize)
       
        let interpreter = MachoModel<JYSymbolTableEntryModel>.init().generateVessel(data: symbolTableData, is64Bit: is64Bit)
         
        
        return SymbolTableInterpretModel(with: symbolTableData, is64Bit: is64Bit, interpreter: interpreter, title: "Symbol Table", subTitle: "__LINKEDIT")
         
    }
    
    // stringTable解释器
    
    func stringTableInterpreter(with symbolTableCommand:JYSymbolTableCommand , is64Bit:Bool , data:DataSlice) -> StringTableInterpretModel{
       
        let stringTableStartOffset = Int(symbolTableCommand.stringTableOffset)
        let symbolTableStartOffset = Int(symbolTableCommand.symbolTableOffset)
        let stringTableSize = Int(symbolTableCommand.stringTableSize)
        let stringTableData = data.interception(from: stringTableStartOffset, length: stringTableSize)
        
        let interpreter = CStringInterpreter(with: stringTableData,
                                             is64Bit: is64Bit,
                                             sectionVirtualAddress: 0,
                                             searchSouce: nil).generatePayload()
        
       return StringTableInterpretModel(with: stringTableData,
                                              is64Bit: is64Bit,
                                              interpreter: interpreter,
                                              title: "String Table",
                                              subTitle: "__LINKEDIT")
    }
    
}
