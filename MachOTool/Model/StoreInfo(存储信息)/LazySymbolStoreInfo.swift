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
    
    let lazySymbolTableList: [LazySymbolEntryModel]
 

    init(with dataSlice: Data,
         is64Bit: Bool,
         title: String,
         subTitle: String? = nil,
         sectionVirtualAddress: UInt64,
         lazySymbolTableList: [LazySymbolEntryModel]) {
        self.lazySymbolTableList = lazySymbolTableList
        super.init(with: dataSlice, title: title, subTitle: subTitle, sectionVirtualAddress: sectionVirtualAddress)
    }
}
