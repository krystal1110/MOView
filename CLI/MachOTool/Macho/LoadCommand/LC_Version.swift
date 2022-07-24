//
//  JYBuildVersionCommand.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/16.
//

import Foundation


extension MachOLoadCommand {
    public struct LC_Version: MachOLoadCommandType {
        
        public var name: String
        public var command: build_version_command? = nil;
        public var dataSlice:Data
        public var version:String
        init(command: build_version_command, dataSlice:Data) {
            let types =   LoadCommandType(rawValue: command.cmd)
            self.name = types?.name ?? " Unknow Command Name "
            self.command = command
            self.dataSlice = dataSlice
            self.version = MachOLoadCommand.LC_Version.versionString(from: 8)
           
        }
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(build_version_command.self, offset: loadCommand.offset)
            let data = loadCommand.data.cutoutData(build_version_command.self, offset: loadCommand.offset)
            self.init(command: command, dataSlice: data)
        }
        
        static func versionString(from versionValue: UInt64) -> String {
            /* A.B.C.D.E packed as a24.b10.c10.d10.e10 */
            let mask: Swift.UInt64 = 0x3ff
            let e = versionValue & mask
            let d = (versionValue >> 10) & mask
            let c = (versionValue >> 20) & mask
            let b = (versionValue >> 30) & mask
            let a = versionValue >> 40
            return String(format: "%d.%d.%d.%d.%d", a, b, c, d, e)
        }
    }
}


//
//class JYBuildVersionCommand: JYLoadCommand {
//    let platform: BuildPlatform?
//    let minOSVersion: String
//    let sdkVersion: String
//    required init(with dataSlice: Data, commandType: LoadCommandType, translationStore: TranslationRead? = nil) {
//        let translationStore = TranslationRead(machoDataSlice: dataSlice).skip(.quadWords)
//
//        platform = translationStore.translate(next: .doubleWords, dataInterpreter: { BuildPlatform(rawValue: $0.UInt32) }, itemContentGenerator: { value in
//            ExplanationModel(description: "Target Platform", explanation: value?.readable ?? "Unkown Platfrom")
//        })
//
//        minOSVersion = translationStore.translate(next: .doubleWords, dataInterpreter: { JYBuildVersionCommand.version(for: $0.UInt32) }, itemContentGenerator: { value in
//            ExplanationModel(description: "Min OS Version", explanation: value)
//        })
//
//        sdkVersion = translationStore.translate(next: .doubleWords, dataInterpreter: { JYBuildVersionCommand.version(for: $0.UInt32) }, itemContentGenerator: { value in
//            ExplanationModel(description: "Min SDK Version", explanation: value)
//        })
//
//        super.init(with: dataSlice, commandType: commandType, translationStore: translationStore)
//    }
//
//    static func version(for value: UInt32) -> String {
//        return String(format: "%d.%d.%d", value >> 16, (value >> 8) & 0xFF, value & 0xFF)
//    }
//}
//
//enum BuildPlatform: UInt32 {
//    case macOS = 1
//    case iOS
//    case tvOS
//    case watchOS
//    case bridgeOS
//    case macCatalyst
//    case iOSSimulator
//    case tvOSSimulator
//    case watchOSSimulator
//    case driverKit
//
//    var readable: String {
//        switch self {
//        case .macOS:
//            return "PLATFORM_MACOS"
//        case .iOS:
//            return "PLATFORM_IOS"
//        case .tvOS:
//            return "PLATFORM_TVOS"
//        case .watchOS:
//            return "PLATFORM_WATCHOS"
//        case .bridgeOS:
//            return "PLATFORM_BRIDGEOS"
//        case .macCatalyst:
//            return "PLATFORM_MACCATALYST"
//        case .iOSSimulator:
//            return "PLATFORM_IOSSIMULATOR"
//        case .tvOSSimulator:
//            return "PLATFORM_TVOSSIMULATOR"
//        case .watchOSSimulator:
//            return "PLATFORM_WATCHOSSIMULATOR"
//        case .driverKit:
//            return "PLATFORM_DRIVERKIT"
//        }
//    }
//}
