//
//  LC_Uuid.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/24.
//

import Foundation


extension MachOLoadCommand {
    public struct LC_Uuid: MachOLoadCommandType {
        
        public var name: String
        private(set) var command: uuid_command? = nil;
        
        init(command: uuid_command) {
            let types =   LoadCommandType(rawValue: command.cmd)
            self.name = types?.name ?? " Unknow Command Name "
            self.command = command
        }
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(uuid_command.self, offset: loadCommand.offset)
            self.init(command: command)
        }
    }
}
