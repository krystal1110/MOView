//
//  LC_EncryptionInfo.swift
//  MachOTool
//
//  Created by karthrine on 2022/7/25.
//

import Foundation


extension MachOLoadCommand {
      struct LC_EncryptionInfo: MachOLoadCommandType {
          var displayStore: DisplayStore
          var command: encryption_info_command? = nil;
          var name: String
        
        init(command: encryption_info_command,displayStore:DisplayStore) {
            let type =   LoadCommandType(rawValue: command.cmd)
            self.name = type?.name ??  "Unknow Command Name"
            self.command = command
            self.displayStore = displayStore
            let translate = Translate(dataSlice: displayStore.dataSlice)
            
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 0, 4), model: ExplanationModel(description: "Load Command Type", explanation:type?.name ?? "" )))
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 4, 8), model: ExplanationModel(description: "Load Command Size", explanation:command.cmdsize.hex)))
            
            translate.translate(from: 8, length: 4, dataInterpreter: {$0.UInt32}) { value in
                ExplanationModel(description: "Crypto File Offset", explanation: value.hex)}
            
            translate.translate(from: 12, length: 4, dataInterpreter: {$0.UInt32}) { value in
                ExplanationModel(description: "Crypto File Size", explanation: value.hex)}
            
            translate.translate(from: 16, length: 4, dataInterpreter: {$0.UInt32}) { value in
                ExplanationModel(description: "Crypto ID", explanation: value.hex)}
            
            
            if type == .encryptionInfo64{
                translate.translate(from: 20, length: 4, dataInterpreter: {$0.UInt32}) { value in
                    ExplanationModel(description: "Crypto Pad", explanation: value.hex)}
            }
            self.displayStore.insert(translate: translate)
            
            self.displayStore.subTitle = self.name
            self.displayStore.extra = "Command Size \(command.cmdsize.hex)"
            
        }
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(encryption_info_command.self, offset: loadCommand.offset)
            self.init(command: command, displayStore:loadCommand.displayStore)
        }
        
        
    }
    
    
}
