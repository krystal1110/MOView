//
//  SymbolTableInterpretInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/21.
//

import Foundation

/*
   符号表解释器
   里面存着符号表的信息
   interpreter -> 符号表数组 里面存放着所有的符号模型(JYSymbolTableEntryModel)
 */

class SymbolTableInterpretInfo:BaseInterpretInfo{
    
    let dataSlice: DataSlice
    let interpreter: SymbolTableInterpreter
    let symbolTableList : Array<JYSymbolTableEntryModel>
    var componentTitle: String { title }
    var componentSubTitle: String? { subTitle }
    let title: String
    let subTitle: String?
    
    init(with dataSlice: DataSlice,
         is64Bit: Bool,
         interpreter: SymbolTableInterpreter,
         symbolTableList: Array<JYSymbolTableEntryModel>,
         title: String,
         subTitle: String? = nil) {
        self.interpreter = interpreter
        self.symbolTableList = symbolTableList
        self.title = title
        self.subTitle = subTitle
        self.dataSlice = dataSlice
    }
    
    
}
