//
//  DynamicSymbolTableCompont.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/15.
//

import Foundation

//dysymtab_command



extension MachOLoadCommand {
    public struct LC_DynamicSymbolTable: MachOLoadCommandType {
        public var displayStore: DisplayStore
        public var name: String
        public var command: dysymtab_command? = nil;
        
        init(command: dysymtab_command, displayStore:DisplayStore) {
            let types =   LoadCommandType(rawValue: command.cmd)
            self.name = types?.name ?? " Unknow Command Name "
            self.command = command
            self.displayStore = displayStore
            let locsymIndexRange =  DataTool.absoluteRange(with:displayStore.dataSlice , start:8, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: locsymIndexRange, model: ExplanationModel(description: "LocSymbol Index", explanation: command.ilocalsym.hex)))
            
            let nlocalsymRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:12, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: nlocalsymRange, model: ExplanationModel(description: "Number of Local Symbols", explanation: command.nlocalsym.hex)))
 
            let iextdefsymRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:16, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: iextdefsymRange, model: ExplanationModel(description: "Defined ExtSymbol Index", explanation: command.iextdefsym.hex)))
             
            let nextdefsymRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:20, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: nextdefsymRange, model: ExplanationModel(description: "Defined ExtSymbol Number", explanation: command.nextdefsym.hex)))
 
            let iundefsymRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:24, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: iundefsymRange, model: ExplanationModel(description: "Undef ExtSymbol Index", explanation: command.iundefsym.hex)))
    
            let nundefsymRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:28, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: nundefsymRange, model: ExplanationModel(description: "Undef ExtSymbol Number", explanation: command.nundefsym.hex)))
      
            let tocoffRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:32, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: tocoffRange, model: ExplanationModel(description: "TOC Offset", explanation: command.ntoc.hex)))
            
            let ntocRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:36, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: ntocRange, model: ExplanationModel(description: "TOC Entries", explanation: command.tocoff.hex)))
    
            let modtaboffRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:40, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: modtaboffRange, model: ExplanationModel(description: "Module Table Offset", explanation: command.modtaboff.hex)))
            
            let nmodtabRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:44, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: nmodtabRange, model: ExplanationModel(description: "Module Table Entries", explanation: command.nmodtab.hex)))
 
            let extrefsymoffRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:48, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: extrefsymoffRange, model: ExplanationModel(description: "ExtRef Table Offset", explanation: command.extrefsymoff.hex)))
            
            let nextrefsymsRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:52, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: nextrefsymsRange, model: ExplanationModel(description: "ExtRef Table Entries", explanation: command.nextrefsyms.hex)))
       
            let indirectsymoffRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:56, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: indirectsymoffRange, model: ExplanationModel(description: "IndSym Table Offset", explanation: command.indirectsymoff.hex)))
   
            let nindirectsymsRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:60, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: nindirectsymsRange, model: ExplanationModel(description: "IndSym Table Entries", explanation: command.nindirectsyms.hex)))

             
            let extreloffRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:64, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: extreloffRange, model: ExplanationModel(description: "ExtReloc Table Offset", explanation: command.extreloff.hex)))

            
            let nextrelRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:68, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: nextrelRange, model: ExplanationModel(description: "ExtReloc Table Entries", explanation: command.nextrel.hex)))

            let locreloffRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:72, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: locreloffRange, model: ExplanationModel(description: "LocReloc Table Offset", explanation: command.locreloff.hex)))
            
            let nlocrelRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:76, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: nlocrelRange, model: ExplanationModel(description: "LocReloc Table Entries", explanation: command.nlocrel.hex)))
      
        }
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(dysymtab_command.self, offset: loadCommand.offset)
            self.init(command: command, displayStore:loadCommand.displayStore)
        }
    }
}



 
