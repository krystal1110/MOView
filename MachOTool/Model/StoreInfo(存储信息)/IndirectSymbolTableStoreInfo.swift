//
//  IndirectSymbolTableStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/23.
//

import Foundation

class IndirectSymbolTableStoreInfo: BaseStoreInfo {
    let indirectSymbolTableList: [IndirectSymbolTableEntryModel]

    init(with dataSlice: Data,
         is64Bit: Bool,
         title: String,
         subTitle: String? = nil,
         indirectSymbolTableList: [IndirectSymbolTableEntryModel]) {
        self.indirectSymbolTableList = indirectSymbolTableList
        super.init(with: dataSlice, title: title, subTitle: subTitle)
    }
}
