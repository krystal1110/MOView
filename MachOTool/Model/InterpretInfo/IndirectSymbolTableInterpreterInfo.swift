//
//  IndirectSymbolTableInterpreterInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/23.
//

import Foundation

class IndirectSymbolTableInterpreterInfo: BaseInterpretInfo {
    let dataSlice: DataSlice
    let indirectSymbolTableList: [IndirectSymbolTableEntryModel]
    var componentTitle: String { title }
    var componentSubTitle: String? { subTitle }
    let title: String
    let subTitle: String?

    init(with dataSlice: DataSlice,
         is64Bit: Bool,
         indirectSymbolTableList: [IndirectSymbolTableEntryModel],
         title: String,
         subTitle: String? = nil) {
        self.indirectSymbolTableList = indirectSymbolTableList
        self.title = title
        self.subTitle = subTitle
        self.dataSlice = dataSlice
    }
}
