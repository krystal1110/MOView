//
//  Interpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/18.
//

import Foundation


protocol Interpreter {
    
    var dataSlice: Data { get }
    var section:Section64? { set get }
    var searchProtocol: SearchProtocol { get set }
}
