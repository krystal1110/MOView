//
//  LC_Load_Dylib.swift
//  MachOTool
//
//  Created by karthrine on 2022/7/24.
//

import Foundation


extension MachOLoadCommand {
    public struct LC_Load_Dylib: MachOLoadCommandType {
         public var command: dylib_command? = nil;
         public var name: String
        public var libPath :String
        
        init(command: dylib_command,displayStore:DisplayStore) {
            let types =   LoadCommandType(rawValue: command.cmd)
            self.name = types?.name ??  "Unknow Command Name"
            self.command = command
             
            let _ = displayStore.translate(from: 8, length: 4, dataInterpreter: {$0.UInt32}) { number in
                ExplanationModel(description: "Path Offset", explanation: "\(number)")
            }
            
            let _ = displayStore.translate(from: 12, length: 4, dataInterpreter: {$0.UInt32}) { number in
                ExplanationModel(description: "Build Time", explanation: "\(number)")
            }
            
            let _ = displayStore.translate(from: 16, length: 4, dataInterpreter: {        MachOLoadCommand.LC_Load_Dylib.version(for: $0.UInt32)}) { version in
                ExplanationModel(description: "Version", explanation: version)
            }
            
            let _ = displayStore.translate(from: 20, length: 4, dataInterpreter: {        MachOLoadCommand.LC_Load_Dylib.version(for: $0.UInt32)}) { version in
                ExplanationModel(description: "Comtatible Version", explanation: version)
            }
            
            let length = (displayStore.dataSlice.count - Int(command.dylib.name.offset))
            self.libPath = displayStore.translate(from: 24, length: length, dataInterpreter: {$0.utf8String?.spaceRemoved ?? "unknow path"}) { path in
                ExplanationModel(description: "Path", explanation: path)
            }
        }
   
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(dylib_command.self, offset: loadCommand.offset)
            self.init(command: command, displayStore:loadCommand.displayStore)
        }
        
        static func version(for value: UInt32) -> String {
            return String(format: "%d.%d.%d", value >> 16, (value >> 8) & 0xff, value & 0xff)
        }
    }
    
   
}
