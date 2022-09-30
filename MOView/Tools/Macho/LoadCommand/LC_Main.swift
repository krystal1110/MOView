//
//  LC_Main.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/15.
//

import Foundation

/*
 struct entry_point_command {
 uint32_t  cmd;    /* LC_MAIN only used in MH_EXECUTE filetypes */
 uint32_t  cmdsize;    /* 24 */
 uint64_t  entryoff;    /* file (__TEXT) offset of main() */
 uint64_t  stacksize; /* if not zero, initial stack size */
 };
 **/

extension MachOLoadCommand {
      struct LC_Main: MachOLoadCommandType {
          var displayStore: DisplayStore
          var name: String
          var command: entry_point_command? = nil;
        
        init(command: entry_point_command, displayStore:DisplayStore) {
            let type =   LoadCommandType(rawValue: command.cmd)
            self.name = type?.name ?? " Unknow Command Name "
            self.command = command
            self.displayStore = displayStore
            
            let translate = Translate(dataSlice: displayStore.dataSlice)
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 0, 4), model: ExplanationModel(description: "Load Command Type", explanation:type?.name ?? "" )))
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 4, 8), model: ExplanationModel(description: "Load Command Size", explanation:command.cmdsize.hex)))
            
            let entryoffRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:8, 4)
            translate.insert(item: ExplanationItem(sourceDataRange: entryoffRange, model: ExplanationModel(description: "Entry Offset", explanation: command.entryoff.hex)))
            
            let stacksizeRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:12, 4)
            translate.insert(item: ExplanationItem(sourceDataRange: stacksizeRange, model: ExplanationModel(description: "Stack Size", explanation: command.stacksize.hex)))
            
            self.displayStore.insert(translate: translate)
            self.displayStore.subTitle = self.name
            self.displayStore.extra = "Command Size \(command.cmdsize.hex)"
        }
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(entry_point_command.self, offset: loadCommand.offset)
            self.init(command: command,displayStore: loadCommand.displayStore)
        }
    }
}
