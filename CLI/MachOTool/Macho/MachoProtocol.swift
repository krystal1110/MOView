//
//  SearchProtocol.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/23.
//

import Foundation

 

protocol SearchProtocol: AnyObject {
    
    func getTEXTConst(_ address: UInt64) -> section_64?
    
    func getMax() -> Int
    
    func getMachoData() -> Data
    
    func getOffsetFromVmAddress(_ address: UInt64) -> UInt64
    
    // 根据offset -> 在stringSymbol查找 symbolName
    func stringInStringTable(at offset: Int) -> String?

 
    // 查找字符串根据 SymbolTableList数组中的索引index查找符号
    func searchStringInSymbolTableIndex(at index: Int)  -> String?
    
    
    // 根据index在间接符号表（IndirectSymbolTable）找到对应的 String
    func searchInIndirectSymbolTableList(at index: Int) -> String?
    
    
    
    func searchStringInSymbolTable(by nValue:UInt64) -> String?
    
    
    func findSymbol(at value:UInt64) -> String
    
    // search section name
    func sectionName(at ordinal: Int) -> String
    
}
