//
//  LC_Rpatch.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/24.
//

import Foundation
import MachO


extension MachOLoadCommand {
    public struct LC_Rpath: MachOLoadCommandType {
        
        public var name: String
        public var command: rpath_command? = nil;
        public var dataSlice:Data
        public var path: String? = nil
        init(command: rpath_command, dataSlice:Data) {
            let types =   LoadCommandType(rawValue: command.cmd)
            self.name = types?.name ?? " Unknow Command Name "
            self.command = command
            self.dataSlice = dataSlice
    
           let straddress =  dataSlice.count - Int(command.path.offset)
            if let str = DataTool.interception(with: dataSlice, from: 12, length: straddress).utf8String{
                self.path = str.spaceRemoved
            }
           
        }
        
        init(loadCommand: MachOLoadCommand) {
            
            let command = loadCommand.data.extract(rpath_command.self, offset: loadCommand.offset)
            let data = DataTool.interception(with: loadCommand.data, from: loadCommand.offset, length: Int(command.cmdsize))
            self.init(command: command,dataSlice: data)
        }
    }
}
