//
//  LC_Uuid.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/24.
//

import Foundation


extension MachOLoadCommand {
      struct LC_Uuid: MachOLoadCommandType {
          var displayStore: DisplayStore
          var name: String
          var command: uuid_command? = nil;
          var uuid:UUID
        
        init(command: uuid_command,displayStore:DisplayStore) {
            let type =   LoadCommandType(rawValue: command.cmd)
            self.name = type?.name ?? " Unknow Command Name "
            self.command = command
            self.displayStore = displayStore
            
            let translate = Translate(dataSlice: displayStore.dataSlice)
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 0, 4), model: ExplanationModel(description: "Load Command Type", explanation:type?.name ?? "" )))
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 4, 8), model: ExplanationModel(description: "Load Command Size", explanation:command.cmdsize.hex)))
            
            self.uuid = translate.translate(from: 8, length: 16, dataInterpreter: {MachOLoadCommand.LC_Uuid.uuid(from: [UInt8]($0))}) { uuid in
                ExplanationModel(description: "UUID", explanation: uuid.uuidString)
            }
            
            self.displayStore.insert(translate: translate)
            self.displayStore.subTitle = self.name
            self.displayStore.extra = "Command Size \(command.cmdsize.hex)"
            
        }
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(uuid_command.self, offset: loadCommand.offset)
            self.init(command: command,displayStore: loadCommand.displayStore)
        }
        
        static func uuid(from uuidData: [UInt8]) -> UUID {
            return UUID(uuid: (uuidData[0], uuidData[1], uuidData[2], uuidData[3], uuidData[4], uuidData[5], uuidData[6], uuidData[7],
                               uuidData[8], uuidData[9], uuidData[10], uuidData[11], uuidData[12], uuidData[13], uuidData[14], uuidData[15]))
        }
    }
    
 
}
