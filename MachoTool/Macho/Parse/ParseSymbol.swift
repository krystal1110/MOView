//
//  ParseSYMTAB.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/27.
//

import Foundation
import MachO



/*
    用于解析 String Table / Symbol Table / Indirect Symbol Table
 **/
class ParseSymbol{
    
    
    var componts: [ComponentInfo] = []
    
    
    func parseSymbol(_ data:Data ,commonds: [MachOLoadCommandType], searchProtocol: SearchProtocol){
        
        
        for item in commonds {
            
            if item.name  == LoadCommandType.symbolTable.name {
                let command =  item as! MachOLoadCommand.LC_SymbolTable
                parseSymbolTable(data, command: command.command!, searchProtocol: searchProtocol)
            }
        }
        
        print("🔥🔥🔥 解析 Symbol Table 完成  🔥🔥🔥")
        
    }
        
    
    
    // Parse SymbolTable
    func parseSymbolTable(_ data: Data , command: symtab_command , searchProtocol: SearchProtocol) {
        let symbolTableStartOffset = Int(command.symoff)
        let numberOfEntries = Int(command.nsyms)
        let entrySize = 16
        let modelSize :Int = 16
        
        let symbolTableData = DataTool.interception(with: data, from: symbolTableStartOffset, length: numberOfEntries * entrySize)
        
       
        let numberOfModels = symbolTableData.count / modelSize
        var models: [SymbolTableModel] = []
        for index in 0 ..< numberOfModels {
            let startIndex = index * modelSize
            let modelData = DataTool.interception(with: symbolTableData, from: startIndex, length: modelSize)
            let model = SymbolTableModel(with: modelData, searchProtocol: searchProtocol)
            models.append(model)
        }
        let compont =   SymbolTableComponent(symbolTableData, symbolTableList: models)
        componts.append(compont)
    }
    
    
 
    
    
    
    func parseStringTable(with  data: Data , command: symtab_command , searchProtocol: SearchProtocol){
        
        let stringTableStartOffset = Int(command.stroff)
        
        let stringTableSize = Int(command.strsize)
        
        let stringTableData = DataTool.interception(with: data, from: stringTableStartOffset, length: stringTableSize)
        
        
        let interpreter = StringInterpreter(with: data, section: nil, searchProtocol: searchProtocol)
       
        let stringTableList = interpreter.transitionData()
        
        let compont = StringComponent(data, section: nil, stringList: stringTableList)
        
        componts.append(compont)
    }
    
    
    
}
