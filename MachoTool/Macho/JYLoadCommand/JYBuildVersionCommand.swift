//
//  JYBuildVersionCommand.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/16.
//

import Foundation


class JYBuildVersionCommand : JYLoadCommand{
    
    let platform: BuildPlatform?
    let minOSVersion: String
    let sdkVersion: String
    required init(with dataSlice: JYDataSlice, commandType: LoadCommandType, translationStore: JYTranslationRead? = nil) {
        let translationStore = JYTranslationRead(machoDataSlice: dataSlice).skip(.quadWords)
        
        self.platform = translationStore.translate(next: .doubleWords, dataInterpreter: {BuildPlatform(rawValue: $0.UInt32)}, itemContentGenerator:{ value in
            ExplanationModel.init(description: "Target Platform", explanation: value?.readable ?? "Unkown Platfrom")
        })
        
        self.minOSVersion = translationStore.translate(next: .doubleWords, dataInterpreter: {JYBuildVersionCommand.version(for: $0.UInt32)}, itemContentGenerator:{ value in
            ExplanationModel.init(description: "Min OS Version", explanation: value)
        })
        
        self.sdkVersion = translationStore.translate(next: .doubleWords, dataInterpreter: {JYBuildVersionCommand.version(for: $0.UInt32)}, itemContentGenerator:{ value in
            ExplanationModel.init(description: "Min SDK Version", explanation: value)
        })
 
        super.init(with: dataSlice, commandType: commandType, translationStore: translationStore)
    }
    
    
    static func version(for value: UInt32) -> String {
        return String(format: "%d.%d.%d", value >> 16, (value >> 8) & 0xff, value & 0xff)
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
