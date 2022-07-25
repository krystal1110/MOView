//
//  LC_SourceVersion.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/16.
//

import Foundation


extension MachOLoadCommand {
    public struct LC_SourceVersion: MachOLoadCommandType {
        
        public var name: String
        public var command: source_version_command? = nil;
        public var version:String
        init(command: source_version_command, displayStore:DisplayStore) {
            let types =   LoadCommandType(rawValue: command.cmd)
            self.name = types?.name ?? " Unknow Command Name "
            self.command = command
            self.version = displayStore.translate(from: 8, length: 8, dataInterpreter: {MachOLoadCommand.LC_SourceVersion.versionString(from:$0.UInt64)}) { version in
                ExplanationModel(description: "Source Version", explanation: version)
            }
        }
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(source_version_command.self, offset: loadCommand.offset)
            self.init(command: command,displayStore: loadCommand.displayStore)
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
