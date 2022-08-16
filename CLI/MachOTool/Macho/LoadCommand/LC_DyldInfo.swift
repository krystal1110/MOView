//
//  DyldInfoCommand.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/6.
//

import Foundation


extension MachOLoadCommand {
    public struct LC_DyldInfo: MachOLoadCommandType {
        public var displayStore: DisplayStore
        public var name: String
        public var command: dyld_info_command
        
        init(command: dyld_info_command, displayStore:DisplayStore) {
            let types =   LoadCommandType(rawValue: command.cmd)
            self.name = types?.name ?? " Unknow Command Name "
            self.command = command
            self.displayStore = displayStore
            let rebaseoffRange =  DataTool.absoluteRange(with:displayStore.dataSlice , start:8, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: rebaseoffRange, model: ExplanationModel(description: "File Offset To Rebase Info", explanation: command.rebase_off.hex)))
            
            let rebaseSizeRange =  DataTool.absoluteRange(with:displayStore.dataSlice , start:12, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: rebaseSizeRange, model: ExplanationModel(description: "Size Of Rebase Info", explanation: command.rebase_size.hex)))
            
            let bindoffRange =  DataTool.absoluteRange(with:displayStore.dataSlice , start:12, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: bindoffRange, model: ExplanationModel(description: "File Offset To Binding Info", explanation: command.bind_off.hex)))
            
            
            let bindsizeRange =  DataTool.absoluteRange(with:displayStore.dataSlice , start:20, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: bindsizeRange, model: ExplanationModel(description: "Size Of Binding Info", explanation: command.bind_size.hex)))
 
            
            let weakbindoffRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:24, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: weakbindoffRange, model: ExplanationModel(description: "File Offset To Weak Binding Info", explanation: command.weak_bind_off.hex)))

            let weakbindsizeRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:28, MemoryLayout<UInt32>.size)
            displayStore.insert(item: ExplanationItem(sourceDataRange: weakbindsizeRange, model: ExplanationModel(description: "Size Of Weak Binding Info", explanation: command.weak_bind_size.hex)))
        }
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(dyld_info_command.self, offset: loadCommand.offset)
            self.init(command: command,displayStore:loadCommand.displayStore)
        }
    }
}
