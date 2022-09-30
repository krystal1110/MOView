//
//  LC_SourceVersion.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/16.
//

import Foundation


extension MachOLoadCommand {
      struct LC_SourceVersion: MachOLoadCommandType {
          var displayStore: DisplayStore
          var name: String
          var command: source_version_command? = nil;
          var version:String
        init(command: source_version_command, displayStore:DisplayStore) {
            let type =   LoadCommandType(rawValue: command.cmd)
            self.name = type?.name ?? " Unknow Command Name "
            self.command = command
            self.displayStore = displayStore
            let translate = Translate(dataSlice: displayStore.dataSlice)
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 0, 4), model: ExplanationModel(description: "Load Command Type", explanation:type?.name ?? "" )))
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 4, 8), model: ExplanationModel(description: "Load Command Size", explanation:command.cmdsize.hex)))
            
            self.version = translate.translate(from: 8, length: 8, dataInterpreter: {MachOLoadCommand.LC_SourceVersion.versionString(from:$0.UInt64)}) { version in
                ExplanationModel(description: "Source Version", explanation: version)
            }
            self.displayStore.insert(translate: translate)
            self.displayStore.subTitle = self.name
            self.displayStore.extra = "Command Size \(command.cmdsize.hex)"
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
