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
        public var command: uuid_command? = nil;
        public var dataSlice:Data
        public var uuid:UUID
        
        init(command: uuid_command,dataSlice:Data) {
            let types =   LoadCommandType(rawValue: command.cmd)
            self.name = types?.name ?? " Unknow Command Name "
            self.command = command
            self.dataSlice = dataSlice
            let uuidData = DataTool.interception(with: dataSlice, from: 8, length: 16)
            self.uuid = MachOLoadCommand.LC_Uuid.uuid(from: [UInt8](uuidData))
            
        }
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(uuid_command.self, offset: loadCommand.offset)
            let data = loadCommand.data.cutoutData(uuid_command.self, offset: loadCommand.offset)
            self.init(command: command,dataSlice: data)
        }
        
        static func uuid(from uuidData: [UInt8]) -> UUID {
            return UUID(uuid: (uuidData[0], uuidData[1], uuidData[2], uuidData[3], uuidData[4], uuidData[5], uuidData[6], uuidData[7],
                               uuidData[8], uuidData[9], uuidData[10], uuidData[11], uuidData[12], uuidData[13], uuidData[14], uuidData[15]))
        }
    }
    
 
}
