//
//  MachoProtocol.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/23.
//

import Foundation


protocol MachoProtocol: AnyObject {
    // 根据offset -> 在stringSymbol查找 symbolName
    func stringInStringTable(at offset: Int) -> String?
    
    // 根据index在SymbolTable中找到对应的SymbolTableEntryModel
    func indexInSymbolTable(at index:Int) -> JYSymbolTableEntryModel?
    
    // 根据index在间接符号表（IndirectSymbolTable）找到对应的 IndirectSymbolTableEntryModel
    func indexInIndirectSymbolTable(at index: Int) -> IndirectSymbolTableEntryModel?
}
