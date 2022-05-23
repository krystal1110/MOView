//
//  IndirectSymbolTableInterpreterInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/23.
//

import Foundation

class IndirectSymbolTableInterpreterInfo:BaseInterpretInfo{
    let dataSlice: DataSlice
    let interpreter: Array<IndirectSymbolTableEntryModel>
    var componentTitle: String { title }
    var componentSubTitle: String? { subTitle }
    let title: String
    let subTitle: String?
    
    init(with dataSlice: DataSlice,
         is64Bit: Bool,
         interpreter: Array<IndirectSymbolTableEntryModel>,
         title: String,
         subTitle: String? = nil) {
        self.interpreter = interpreter
        self.title = title
        self.subTitle = subTitle
        self.dataSlice = dataSlice
    }
    
    
}
