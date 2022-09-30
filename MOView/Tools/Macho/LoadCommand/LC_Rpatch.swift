//
//  LC_Rpatch.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/24.
//

import Foundation
import MachO


extension MachOLoadCommand {
      struct LC_Rpath: MachOLoadCommandType {
          var displayStore: DisplayStore
          var name: String
          var command: rpath_command? = nil;
          var path: String? = nil
        init(command: rpath_command, displayStore:DisplayStore) {
            let type =   LoadCommandType(rawValue: command.cmd)
            self.name = type?.name ?? " Unknow Command Name "
            self.command = command
            self.displayStore = displayStore
            let translate = Translate(dataSlice: displayStore.dataSlice)
            
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 0, 4), model: ExplanationModel(description: "Load Command Type", explanation:type?.name ?? "" )))
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 4, 8), model: ExplanationModel(description: "Load Command Size", explanation:command.cmdsize.hex)))
            
            let entryoffRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:8, 4)
            translate.insert(item: ExplanationItem(sourceDataRange: entryoffRange, model: ExplanationModel(description: "Path Offset", explanation: command.path.offset.hex)))
            
            self.path = translate.translate(from: 12, length: (displayStore.dataSlice.count - Int(command.path.offset)), dataInterpreter: {$0.utf8String?.spaceRemoved ?? "unknow path"}) { path in
                ExplanationModel(description: "Path", explanation: path)
            }
            self.displayStore.insert(translate: translate)
            if let path = self.path {
                self.displayStore.subTitle = self.name + "(\(path)"
            }else{
                self.displayStore.subTitle = self.name
            }
            self.displayStore.extra = "Command Size \(command.cmdsize.hex)"
        }
        
        init(loadCommand: MachOLoadCommand) {
            
            let command = loadCommand.data.extract(rpath_command.self, offset: loadCommand.offset)
            self.init(command: command,displayStore: loadCommand.displayStore)
        }
    }
}
