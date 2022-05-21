//
//  JYSymbolTableInterpreter.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/16.
//

import Foundation


class JYSymbolTableInterpreter{
    
    // symbolTable解释器
    func symbolTableInterpreter(with symbolTableCommand:JYSymbolTableCommand , is64Bit:Bool , data:JYDataSlice){
        
        let symbolTableStartOffset = Int(symbolTableCommand.symbolTableOffset)
        let numberOfEntries = Int(symbolTableCommand.numberOfSymbolTable)
        let entrySize = is64Bit ? 16 : 12
        let symbolTableData = data.interception(from: symbolTableStartOffset, length: numberOfEntries * entrySize)
       
        JYMachoModel<JYSymbolTableEntryModel>.init().generateVessel(data: symbolTableData, is64Bit: is64Bit)
        
    }
    
    // stringTable解释器
    
    func stringTableInterpreter(with symbolTableCommand:JYSymbolTableCommand , is64Bit:Bool , data:JYDataSlice){
        let stringTableStartOffset = Int(symbolTableCommand.stringTableOffset)
        let symbolTableStartOffset = Int(symbolTableCommand.symbolTableOffset)
        let stringTableSize = Int(symbolTableCommand.stringTableSize)
        let stringTableData = data.interception(from: stringTableStartOffset, length: stringTableSize)
        
        
    }
    
}
