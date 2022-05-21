//
//  SymbolTableInterpretModel.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/21.
//

import Foundation


class SymbolTableInterpretModel{
    
    let dataSlice: DataSlice
    let interpreter: Array<JYSymbolTableEntryModel>
    
    var componentTitle: String { title }
    var componentSubTitle: String? { subTitle }
    let title: String
    let subTitle: String?
    
    init(with dataSlice: DataSlice,
         is64Bit: Bool,
         interpreter: Array<JYSymbolTableEntryModel>,
         title: String,
         subTitle: String? = nil) {
        self.interpreter = interpreter
        self.title = title
        self.subTitle = subTitle
        self.dataSlice = dataSlice
    }
    
    
}
