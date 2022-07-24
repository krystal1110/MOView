//
//  LC_Load_Dylib.swift
//  MachOTool
//
//  Created by karthrine on 2022/7/24.
//

import Foundation


extension MachOLoadCommand {
    public struct LC_Load_Dylib: MachOLoadCommandType {
        
        public var name: String
        public var command: dylib_command? = nil;
        public var dataSlice:Data
 
        
        init(command: dylib_command,dataSlice:Data) {
            let types =   LoadCommandType(rawValue: command.cmd)
            self.name = types?.name ??  "Unknow Command Name"
            self.command = command
            self.dataSlice = dataSlice
        }
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(dylib_command.self, offset: loadCommand.offset)
            let data = loadCommand.data.cutoutData(dylib_command.self, offset: loadCommand.offset)
            self.init(command: command,dataSlice: data)
        }
    }
}
