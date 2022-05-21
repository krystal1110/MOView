//
//  StringTableInterpretModel.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/21.
//

import Foundation

class StringTableInterpretModel{
    
    let dataSlice: DataSlice
    let interpreter: Array<CStringPosition>
    
    var componentTitle: String { title }
    var componentSubTitle: String? { subTitle }
    let title: String
    let subTitle: String?
    
    init(with dataSlice: DataSlice,
         is64Bit: Bool,
         interpreter: Array<CStringPosition>,
         title: String,
         subTitle: String? = nil) {
        self.interpreter = interpreter
        self.title = title
        self.subTitle = subTitle
        self.dataSlice = dataSlice
    }
    
    
}
