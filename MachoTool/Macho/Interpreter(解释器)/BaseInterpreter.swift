//
//  BaseInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/18.
//

import Foundation

class BaseInterpreter {
    
    let data: Data
    let SearchProtocol: SearchProtocol
    let is64Bit: Bool
    let sectionVirtualAddress: UInt64
    let startOffset: Int // 初始偏移量
    let count: Int
       
    init(_ data:Data, is64Bit:Bool, SearchProtocol:SearchProtocol, sectionVirtualAddress:UInt64) {
        
        self.data = data
        self.is64Bit = is64Bit
        self.SearchProtocol = SearchProtocol
        self.sectionVirtualAddress = sectionVirtualAddress
        self.startOffset = .zero
        self.count = data.count
    }
    
}


protocol Interpreter {
    
    var dataSlice: Data { get }
    var section:Section64? { set get }
    var searchProtocol: SearchProtocol { get set }
}
