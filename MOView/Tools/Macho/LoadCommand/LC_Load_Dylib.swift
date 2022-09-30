//
//  LC_Load_Dylib.swift
//  MachOTool
//
//  Created by karthrine on 2022/7/24.
//

import Foundation


extension MachOLoadCommand {
      struct LC_Load_Dylib: MachOLoadCommandType {
          var displayStore: DisplayStore
          var command: dylib_command? = nil;
          var name: String
          var libPath :String
        
        init(command: dylib_command,displayStore:DisplayStore) {
            let type =   LoadCommandType(rawValue: command.cmd)
            self.name = type?.name ??  "Unknow Command Name"
            self.command = command
            self.displayStore = displayStore
            
            let translate = Translate(dataSlice: displayStore.dataSlice)
            
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 0, 4), model: ExplanationModel(description: "Load Command Type", explanation:type?.name ?? "" )))
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 4, 8), model: ExplanationModel(description: "Load Command Size", explanation:command.cmdsize.hex)))
            
            translate.translate(from: 8, length: 4, dataInterpreter: {$0.UInt32}) { number in
                ExplanationModel(description: "Path Offset", explanation: "\(number)")
            }
            
            translate.translate(from: 12, length: 4, dataInterpreter: {$0.UInt32}) { number in
                ExplanationModel(description: "Build Time", explanation: "\(number)")
            }
            
            translate.translate(from: 16, length: 4, dataInterpreter: {        MachOLoadCommand.LC_Load_Dylib.version(for: $0.UInt32)}) { version in
                ExplanationModel(description: "Version", explanation: version)
            }
            
            translate.translate(from: 20, length: 4, dataInterpreter: {        MachOLoadCommand.LC_Load_Dylib.version(for: $0.UInt32)}) { version in
                ExplanationModel(description: "Comtatible Version", explanation: version)
            }
            
            let length = (displayStore.dataSlice.count - Int(command.dylib.name.offset))
            self.libPath = translate  .translate(from: 24, length: length, dataInterpreter: {$0.utf8String?.spaceRemoved ?? ""}) { path in
                ExplanationModel(description: "Path", explanation: path)
            }
            
            
            if !self.libPath.isEmpty {
                let array : Array = self.libPath.components(separatedBy: "/")
                self.displayStore.subTitle = self.name + "(\(array.last ?? "" ))"
            }else{
                self.displayStore.subTitle = self.name
            }
            self.displayStore.insert(translate: translate)
            self.displayStore.extra = "Command Size \(command.cmdsize.hex)"
            
        }
   
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(dylib_command.self, offset: loadCommand.offset)
            self.init(command: command, displayStore:loadCommand.displayStore)
        }
        
        static func version(for value: UInt32) -> String {
            return String(format: "%d.%d.%d", value >> 16, (value >> 8) & 0xff, value & 0xff)
        }
    }
    
   
}
