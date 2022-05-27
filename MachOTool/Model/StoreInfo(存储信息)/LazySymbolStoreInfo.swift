//
//  LazySymbolStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/26.
//

import Foundation

/*
  用于存储懒加载符号表以及非懒加载符号表信息
 **/
class LazySymbolStoreInfo: BaseStoreInfo {
    let dataSlice: DataSlice
    let lazySymbolTableList: [LazySymbolEntryModel]
    
    var componentTitle: String { title }
    var componentSubTitle: String? { subTitle }
    let title: String
    let subTitle: String?

    init(with dataSlice: DataSlice,
         is64Bit: Bool,
         lazySymbolTableList: [LazySymbolEntryModel],
         title: String,
         subTitle: String? = nil) {
        self.lazySymbolTableList = lazySymbolTableList
        self.title = title
        self.subTitle = subTitle
        self.dataSlice = dataSlice
    }
}
