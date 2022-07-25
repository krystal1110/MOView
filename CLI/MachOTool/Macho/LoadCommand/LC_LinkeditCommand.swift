//
//  LC_Code_Signature.swift
//  MachOTool
//
//  Created by karthrine on 2022/7/24.
//

import Foundation

//public struct linkedit_data_command {
//
//    public init()
//
//    public init(cmd: UInt32, cmdsize: UInt32, dataoff: UInt32, datasize: UInt32)
//
//    public var cmd: UInt32 /* LC_CODE_SIGNATURE, LC_SEGMENT_SPLIT_INFO,
//                   LC_FUNCTION_STARTS, LC_DATA_IN_CODE,
//                   LC_DYLIB_CODE_SIGN_DRS,
//                   LC_LINKER_OPTIMIZATION_HINT,
//                   LC_DYLD_EXPORTS_TRIE, or
//                   LC_DYLD_CHAINED_FIXUPS. */
//
//
//    public var cmdsize: UInt32 /* sizeof(struct linkedit_data_command) */
//
//    public var dataoff: UInt32 /* file offset of data in __LINKEDIT segment */
//
//    public var datasize: UInt32 /* file size of data in __LINKEDIT segment  */
//}

extension MachOLoadCommand {
    public struct LC_LinkeditCommand: MachOLoadCommandType {
        public var displayStore: DisplayStore
        public var name: String
        public var command: linkedit_data_command? = nil;
        
        init(command: linkedit_data_command,displayStore:DisplayStore) {
            let types =   LoadCommandType(rawValue: command.cmd)
            self.name = types?.name ?? " Unknow Command Name "
            self.command = command
            self.displayStore = displayStore
            let dataoffRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:8, 4)
            displayStore.insert(item: ExplanationItem(sourceDataRange: dataoffRange, model: ExplanationModel(description: "Data Offset", explanation: command.dataoff.hex)))
            
        
            let datasizeRange =  DataTool.absoluteRange(with: displayStore.dataSlice, start:12, 4)
            displayStore.insert(item: ExplanationItem(sourceDataRange: datasizeRange, model: ExplanationModel(description: "Data Size", explanation: command.datasize.hex)))
        }
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(linkedit_data_command.self, offset: loadCommand.offset)
            self.init(command: command,displayStore:loadCommand.displayStore)
        }
    }
}
