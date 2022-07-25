//
//  LC_Unknown.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/24.
//

import Foundation


extension MachOLoadCommand {
    public struct LC_Unknown: MachOLoadCommandType {
        public var displayStore: DisplayStore
        public var name: String
        public var data: Data? = nil;
        
        init(loadCommand: MachOLoadCommand) {
            self.displayStore = loadCommand.displayStore
            let types =   LoadCommandType(rawValue: loadCommand.command)
            self.name = types?.name ?? " Unknow Command Name "
            self.data =  DataTool.interception(with: loadCommand.data, from: loadCommand.offset, length: loadCommand.size)
            
        }
    }
}
