//
//  LC_BuildVersion.swift
//  MachOTool
//
//  Created by karthrine on 2022/7/25.
//
 
import Foundation


extension MachOLoadCommand {
      struct LC_BuildVersion: MachOLoadCommandType {
          var displayStore: DisplayStore
          var name: String
          var command: build_version_command? = nil;
        let buildTools: [LCBuildTool]
        
        init(command: build_version_command, displayStore:DisplayStore) {
            let type =   LoadCommandType(rawValue: command.cmd)
            self.name = type?.name ?? " Unknow Command Name "
            self.command = command
            self.displayStore = displayStore
            let translate = Translate(dataSlice: displayStore.dataSlice)
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 0, 4), model: ExplanationModel(description: "Load Command Type", explanation:type?.name ?? "" )))
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 4, 8), model: ExplanationModel(description: "Load Command Size", explanation:command.cmdsize.hex)))
            
            let _  =  translate.translate(from: 8, length: 4, dataInterpreter: {BuildPlatform(rawValue: $0.UInt32)}) { platform in
                ExplanationModel(description: "Target Platform", explanation: platform?.readable ?? "unkonw")
            }
            
            let _ = translate.translate(from: 12, length: 4, dataInterpreter: {MachOLoadCommand.LC_BuildVersion.version(for: $0.UInt32)}){ version in
                ExplanationModel(description: "Min OS Version", explanation: version)
            }
             
            let _ = translate.translate(from: 16, length: 4, dataInterpreter: {MachOLoadCommand.LC_BuildVersion.version(for: $0.UInt32)}){ version in
                ExplanationModel(description: "Min SDK Version", explanation: version)
            }
            
            let numberOfTools = translate.translate(from: 20, length: 4, dataInterpreter: {$0.UInt32}){ value in
                ExplanationModel(description: "Number of tool entries", explanation: "\(value)")
            }
            
            var form:Int = 24
            var tools: [LCBuildTool] = []
            for _ in 0..<numberOfTools{
                let toolType = translate.translate(from: form, length: 4, dataInterpreter: {BuildToolType(rawValue: $0.UInt32)!}){ tool in
                    ExplanationModel(description: "Build Tool", explanation: tool.readable)
                }
                form = form + 4
                
                let toolVersion = translate.translate(from: form, length: 4, dataInterpreter: {MachOLoadCommand.LC_BuildVersion.version(for: $0.UInt32)}){ toolVersion in
                    ExplanationModel(description: "Tool Version", explanation: toolVersion)
                }
                form = form + 4
                tools.append(LCBuildTool(toolType: toolType, version: toolVersion))
            }
            self.buildTools = tools
            
            self.displayStore.insert(translate: translate)
            self.displayStore.subTitle = self.name
            self.displayStore.extra = "Command Size \(command.cmdsize.hex)"
        }
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(build_version_command.self, offset: loadCommand.offset)
            self.init(command: command,displayStore: loadCommand.displayStore)
        }
        
        static func version(for value: UInt32) -> String {
            return String(format: "%d.%d.%d", value >> 16, (value >> 8) & 0xff, value & 0xff)
        }
    }
}

enum BuildPlatform: UInt32 {
    case macOS = 1
    case iOS
    case tvOS
    case watchOS
    case bridgeOS
    case macCatalyst
    case iOSSimulator
    case tvOSSimulator
    case watchOSSimulator
    case driverKit
    
    var readable: String {
        switch self {
        case .macOS:
            return "PLATFORM_MACOS"
        case .iOS:
            return "PLATFORM_IOS"
        case .tvOS:
            return "PLATFORM_TVOS"
        case .watchOS:
            return "PLATFORM_WATCHOS"
        case .bridgeOS:
            return "PLATFORM_BRIDGEOS"
        case .macCatalyst:
            return "PLATFORM_MACCATALYST"
        case .iOSSimulator:
            return "PLATFORM_IOSSIMULATOR"
        case .tvOSSimulator:
            return "PLATFORM_TVOSSIMULATOR"
        case .watchOSSimulator:
            return "PLATFORM_WATCHOSSIMULATOR"
        case .driverKit:
            return "PLATFORM_DRIVERKIT"
        }
    }
}

struct LCBuildTool {
    let toolType: BuildToolType
    let version: String
}

enum BuildToolType: UInt32 {
    case clang = 1
    case swift
    case ld
    
    var readable: String {
        switch self {
        case .clang:
            return "Clang (TOOL_CLANG)"
        case .swift:
            return "Swift (TOOL_SWIFT)"
        case .ld:
            return "LD (TOOL_LD)"
        }
    }
}
