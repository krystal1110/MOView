//
//  LC_Code_Signature.swift
//  MachOTool
//
//  Created by karthrine on 2022/7/24.
//

import Foundation

//  struct linkedit_data_command {
//
//      init()
//
//      init(cmd: UInt32, cmdsize: UInt32, dataoff: UInt32, datasize: UInt32)
//
//      var cmd: UInt32 /* LC_CODE_SIGNATURE, LC_SEGMENT_SPLIT_INFO,
//                   LC_FUNCTION_STARTS, LC_DATA_IN_CODE,
//                   LC_DYLIB_CODE_SIGN_DRS,
//                   LC_LINKER_OPTIMIZATION_HINT,
//                   LC_DYLD_EXPORTS_TRIE, or
//                   LC_DYLD_CHAINED_FIXUPS. */
//
//
//      var cmdsize: UInt32 /* sizeof(struct linkedit_data_command) */
//
//      var dataoff: UInt32 /* file offset of data in __LINKEDIT segment */
//
//      var datasize: UInt32 /* file size of data in __LINKEDIT segment  */
//}

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
