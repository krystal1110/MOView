//
//  UStringStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/31.
//

import Foundation

class UStringStoreInfo: BaseStoreInfo {
    let interpreter: UStringInterpreter
    let uStringPositionList: [UStringPosition]

    init(with dataSlice: Data,
         interpreter: UStringInterpreter,
         title: String,
         subTitle: String? = nil,
         sectionVirtualAddress: UInt64,
         uStringPositionList: [UStringPosition]) {
        self.uStringPositionList = uStringPositionList
        self.interpreter = interpreter
        super.init(with: dataSlice, title: title, subTitle: subTitle, sectionVirtualAddress: sectionVirtualAddress)
    }
}
 
