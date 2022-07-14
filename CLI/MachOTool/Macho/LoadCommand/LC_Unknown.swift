//
//  LC_Unknown.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/24.
//

import Foundation


extension MachOLoadCommand {
    public struct LC_Unknown: MachOLoadCommandType {
        
        var name: String
        private(set) var data: Data? = nil;
        
        init(loadCommand: MachOLoadCommand) {
            let types =   LoadCommandType(rawValue: loadCommand.command)
            self.name = types?.name ?? " Unknow Command Name "
            self.data =  DataTool.interception(with: loadCommand.data, from: loadCommand.offset, length: loadCommand.size)
            
        }
    }
}
