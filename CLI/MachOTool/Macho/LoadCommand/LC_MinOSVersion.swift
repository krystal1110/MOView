//
//  LC_MinOSVersion.swift
//  MachOTool
//
//  Created by karthrine on 2022/7/25.
//

import Foundation


extension MachOLoadCommand {
    public struct LC_MinOSVersion: MachOLoadCommandType {
        
        public var name: String
        public var command: version_min_command? = nil;
        
        init(command: version_min_command, displayStore:DisplayStore) {
            let types =   LoadCommandType(rawValue: command.cmd)
            self.name = types?.name ?? " Unknow Command Name "
            self.command = command
             
            
           let name = MachOLoadCommand.LC_MinOSVersion.osName(for: types!)
            
            let _  =  displayStore.translate(from: 8, length: 4, dataInterpreter: {MachOLoadCommand.LC_MinOSVersion.version(for: $0.UInt32)}) { version in
                ExplanationModel(description: "Required \(name) version", explanation:version)
            }
            
            let _  =  displayStore.translate(from: 12, length: 4, dataInterpreter: {MachOLoadCommand.LC_MinOSVersion.version(for: $0.UInt32)}) { version in
                ExplanationModel(description: "Required \(name) SDK version", explanation:version)
            }
            
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
