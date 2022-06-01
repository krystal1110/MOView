//
//  UStringStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/31.
//

import Foundation

class UStringStoreInfo: BaseStoreInfo {
    let dataSlice: DataSlice
    let interpreter: UStringInterpreter
    let uStringPositionList: [UStringPosition]
    var componentTitle: String { title }
    var componentSubTitle: String? { subTitle }
    let title: String
    let subTitle: String?

    init(with dataSlice: DataSlice,
         is64Bit: Bool,
         interpreter: UStringInterpreter,
         uStringPositionList: [UStringPosition],
         title: String,
         subTitle: String? = nil) {
        self.uStringPositionList = uStringPositionList
        self.interpreter = interpreter
        self.title = title
        self.subTitle = subTitle
        self.dataSlice = dataSlice
    }
}
 
