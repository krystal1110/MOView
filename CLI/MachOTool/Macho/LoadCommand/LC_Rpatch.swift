//
//  LC_Rpatch.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/24.
//

import Foundation
import MachO


extension MachOLoadCommand {
    public struct LC_Rpath: MachOLoadCommandType {
        
        public var name: String
        public var command: rpath_command? = nil;
        public var path: String? = nil
        init(command: rpath_command, displayStore:DisplayStore) {
            let types =   LoadCommandType(rawValue: command.cmd)
            self.name = types?.name ?? " Unknow Command Name "
            self.command = command

            let entryoffRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:8, 4)
            displayStore.insert(item: ExplanationItem(sourceDataRange: entryoffRange, model: ExplanationModel(description: "Path Offset", explanation: command.path.offset.hex)))
            
            self.path = displayStore.translate(from: 12, length: (displayStore.dataSlice.count - Int(command.path.offset)), dataInterpreter: {$0.utf8String?.spaceRemoved ?? "unknow path"}) { path in
                ExplanationModel(description: "Path", explanation: path)
            }
        }
        
        init(loadCommand: MachOLoadCommand) {
            
            let command = loadCommand.data.extract(rpath_command.self, offset: loadCommand.offset)
            self.init(command: command,displayStore: loadCommand.displayStore)
        }
    }
}
