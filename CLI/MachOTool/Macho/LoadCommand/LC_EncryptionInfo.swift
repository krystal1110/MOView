//
//  LC_EncryptionInfo.swift
//  MachOTool
//
//  Created by karthrine on 2022/7/25.
//

import Foundation


extension MachOLoadCommand {
    public struct LC_EncryptionInfo: MachOLoadCommandType {
        public var command: encryption_info_command? = nil;
        public var name: String
        
        init(command: encryption_info_command,displayStore:DisplayStore) {
            let types =   LoadCommandType(rawValue: command.cmd)
            self.name = types?.name ??  "Unknow Command Name"
            self.command = command
            
            let _ = displayStore.translate(from: 8, length: 4, dataInterpreter: {$0.UInt32}) { value in
                ExplanationModel(description: "Crypto File Offset", explanation: value.hex)}
            
            let _ = displayStore.translate(from: 12, length: 4, dataInterpreter: {$0.UInt32}) { value in
                ExplanationModel(description: "Crypto File Size", explanation: value.hex)}
            
            let _ = displayStore.translate(from: 16, length: 4, dataInterpreter: {$0.UInt32}) { value in
                ExplanationModel(description: "Crypto ID", explanation: value.hex)}
            
            
            if types == .encryptionInfo64{
                let _ = displayStore.translate(from: 20, length: 4, dataInterpreter: {$0.UInt32}) { value in
                    ExplanationModel(description: "Crypto Pad", explanation: value.hex)}
            }
        }
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(encryption_info_command.self, offset: loadCommand.offset)
            self.init(command: command, displayStore:loadCommand.displayStore)
        }
        
        
    }
    
    
}
