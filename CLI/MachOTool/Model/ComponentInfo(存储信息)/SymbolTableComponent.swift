//
//  SymbolTableStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/21.
//

import Foundation

/*
   符号表存储器
   里面存着符号表的信息
   interpreter -> 符号表数组 里面存放着所有的符号模型(JYSymbolTableEntryModel)
 */

 

public struct SymbolTableComponent:ComponentInfo{
     
    
    public var dataSlice: Data
    public var componentTitle: String?
    public var componentSubTitle: String?
    public var section: Section64?
    public var symbolTableList : [SymbolTableModel]
    
    
    init(_ dataSlice: Data, symbolTableList:[SymbolTableModel] ) {
        self.dataSlice = dataSlice
        self.componentTitle = "Symbol Table"
        self.componentSubTitle = ""
        self.symbolTableList = symbolTableList
    }
    
}
 
