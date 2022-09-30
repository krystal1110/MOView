//
//  LC_MinOSVersion.swift
//  MachOTool
//
//  Created by karthrine on 2022/7/25.
//

import Foundation


extension MachOLoadCommand {
      struct LC_MinOSVersion: MachOLoadCommandType {
          var displayStore: DisplayStore
          var name: String
          var command: version_min_command? = nil;
          
        init(command: version_min_command, displayStore:DisplayStore) {
            let type =   LoadCommandType(rawValue: command.cmd)
            self.name = type?.name ?? " Unknow Command Name "
            self.command = command
            self.displayStore = displayStore
            let translate = Translate(dataSlice: displayStore.dataSlice)
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 0, 4), model: ExplanationModel(description: "Load Command Type", explanation:type?.name ?? "" )))
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 4, 8), model: ExplanationModel(description: "Load Command Size", explanation:command.cmdsize.hex)))
            
           let name = MachOLoadCommand.LC_MinOSVersion.osName(for: type!)
            let _  =  translate.translate(from: 8, length: 4, dataInterpreter: {MachOLoadCommand.LC_MinOSVersion.version(for: $0.UInt32)}) { version in
                ExplanationModel(description: "Required \(name) version", explanation:version)
            }
            
            let _  =  translate.translate(from: 12, length: 4, dataInterpreter: {MachOLoadCommand.LC_MinOSVersion.version(for: $0.UInt32)}) { version in
                ExplanationModel(description: "Required \(name) SDK version", explanation:version)
            }
            
            self.displayStore.insert(translate: translate)
            self.displayStore.subTitle = self.name
            self.displayStore.extra = "Command Size \(command.cmdsize.hex)"
            
        }
          
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(version_min_command.self, offset: loadCommand.offset)
            self.init(command: command,displayStore: loadCommand.displayStore)
        }
        
        static func osName(for type: LoadCommandType) -> String {
            switch type {
            case .iOSMinVersion:
                return "iOS"
            case .macOSMinVersion:
                return "macOS"
            case .tvOSMinVersion:
                return "tvOS"
            case .watchOSMinVersion:
                return "watchOS"
            default:
                fatalError()
            }
        }
        
        static func version(for value: UInt32) -> String {
            return String(format: "%d.%d.%d", value >> 16, (value >> 8) & 0xff, value & 0xff)
        }
    }
}
