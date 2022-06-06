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

class SymbolTableStoreInfo: BaseStoreInfo {
    let interpreter: SymbolTableInterpreter
    let symbolTableList: [JYSymbolTableEntryModel]
 

    init(with dataSlice:Data,
         is64Bit: Bool,
         interpreter: SymbolTableInterpreter,
         title: String,
         subTitle: String? = nil,
         symbolTableList: [JYSymbolTableEntryModel]) {
        self.interpreter = interpreter
        self.symbolTableList = symbolTableList
        super.init(with: dataSlice, title: title, subTitle: subTitle)
        
    }
}
