//
//  BaseInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/18.
//

import Foundation

class BaseInterpreter {
    
    let data: Data
    let machoProtocol: MachoProtocol
    let is64Bit: Bool
    let sectionVirtualAddress: UInt64
    let startOffset: Int // 初始偏移量
    let count: Int
       
    init(_ data:Data, is64Bit:Bool, machoProtocol:MachoProtocol, sectionVirtualAddress:UInt64) {
        
        self.data = data
        self.is64Bit = is64Bit
        self.machoProtocol = machoProtocol
        self.sectionVirtualAddress = sectionVirtualAddress
        self.startOffset = .zero
        self.count = data.count
    }
    
}
