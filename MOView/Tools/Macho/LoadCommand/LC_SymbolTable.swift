//
//  JYSymbolTableCommand.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/15.
//

import Foundation


extension MachOLoadCommand {
      struct LC_SymbolTable: MachOLoadCommandType {
          var displayStore: DisplayStore
          var name: String
          var command: symtab_command? = nil;
        
        init(command: symtab_command, displayStore:DisplayStore) {
            let type =   LoadCommandType(rawValue: command.cmd)
            self.name = type?.name ?? " Unknow Command Name "
            self.command = command
            self.displayStore = displayStore
            
            let translate = Translate(dataSlice: displayStore.dataSlice)
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 0, 4), model: ExplanationModel(description: "Load Command Type", explanation:type?.name ?? "" )))
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 4, 8), model: ExplanationModel(description: "Load Command Size", explanation:command.cmdsize.hex)))
            
            let symtaboffRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:8, MemoryLayout<UInt32>.size)
            translate.insert(item: ExplanationItem(sourceDataRange: symtaboffRange, model: ExplanationModel(description: "Symbol Table Offset", explanation: command.symoff.hex)))
            
            let numofsymRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:12, MemoryLayout<UInt32>.size)
            translate.insert(item: ExplanationItem(sourceDataRange: numofsymRange, model: ExplanationModel(description: "Number of Symbols", explanation: command.nsyms.hex)))
            
      
            let stringtabRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:16, MemoryLayout<UInt32>.size)
            translate.insert(item: ExplanationItem(sourceDataRange: stringtabRange, model: ExplanationModel(description: "String Table Offset", explanation: command.stroff.hex)))
            
            let stringtabsizeRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:16, MemoryLayout<UInt32>.size)
            translate.insert(item: ExplanationItem(sourceDataRange: stringtabsizeRange, model: ExplanationModel(description: "String Table Size", explanation: command.strsize.hex)))
            
            self.displayStore.insert(translate: translate)
            self.displayStore.subTitle = self.name
            self.displayStore.extra = "Command Size \(command.cmdsize.hex)"
            
        }
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(symtab_command.self, offset: loadCommand.offset)
            self.init(command: command,displayStore: loadCommand.displayStore)
        }
    }
}

