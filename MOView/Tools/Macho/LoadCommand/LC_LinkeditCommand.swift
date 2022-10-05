//
//  LC_Code_Signature.swift
//  MachOTool
//
//  Created by karthrine on 2022/7/24.
//

import Foundation
 

extension MachOLoadCommand {
      struct LC_LinkeditCommand: MachOLoadCommandType {
          var displayStore: DisplayStore
          var name: String
          var command: linkedit_data_command? = nil;
        
        init(command: linkedit_data_command,displayStore:DisplayStore) {
            let type =   LoadCommandType(rawValue: command.cmd)
            self.name = type?.name ?? " Unknow Command Name "
            self.command = command
            self.displayStore = displayStore
            let dataoffRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:8, 4)
            
            let translate = Translate(dataSlice: displayStore.dataSlice)
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 0, 4), model: ExplanationModel(description: "Load Command Type", explanation:type?.name ?? "" )))
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 4, 8), model: ExplanationModel(description: "Load Command Size", explanation:command.cmdsize.hex)))
            
            translate.insert(item: ExplanationItem(sourceDataRange: dataoffRange, model: ExplanationModel(description: "Data Offset", explanation: command.dataoff.hex)))
            
        
            let datasizeRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:12, 4)
            translate.insert(item: ExplanationItem(sourceDataRange: datasizeRange, model: ExplanationModel(description: "Data Size", explanation: command.datasize.hex)))
            
            self.displayStore.insert(translate: translate)
            self.displayStore.subTitle = self.name
            self.displayStore.extra = "Command Size \(command.cmdsize.hex)"
        }
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(linkedit_data_command.self, offset: loadCommand.offset)
            self.init(command: command,displayStore:loadCommand.displayStore)
        }
    }
}
