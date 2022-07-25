//
//  JYSymbolTableCommand.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/15.
//

import Foundation


extension MachOLoadCommand {
    public struct LC_SymbolTable: MachOLoadCommandType {
        
        public var name: String
        public var command: symtab_command? = nil;
        
        init(command: symtab_command, displayStore:DisplayStore) {
            let types =   LoadCommandType(rawValue: command.cmd)
            self.name = types?.name ?? " Unknow Command Name "
            self.command = command
            
            
            let symtaboffRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:8, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: symtaboffRange, model: ExplanationModel(description: "Symbol Table Offset", explanation: command.symoff.hex)))
            
            let numofsymRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:12, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: numofsymRange, model: ExplanationModel(description: "Number of Symbols", explanation: command.nsyms.hex)))
            
      
            let stringtabRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:16, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: stringtabRange, model: ExplanationModel(description: "String Table Offset", explanation: command.stroff.hex)))
            
            let stringtabsizeRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:16, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: stringtabsizeRange, model: ExplanationModel(description: "String Table Size", explanation: command.strsize.hex)))
            
        }
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(symtab_command.self, offset: loadCommand.offset)
            self.init(command: command,displayStore: loadCommand.displayStore)
        }
    }
}

