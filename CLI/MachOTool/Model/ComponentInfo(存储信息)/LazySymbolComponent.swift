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

struct LazySymbolComponent: ComponentInfo{
    var typeTitle: String?
    var dataSlice: Data
    var componentTitle: String?
    var componentSubTitle: String?
    var section: Section64?
    var lazySymbolTableList : [LazySymbolEntryModel]
    
    init(_ dataSlice: Data, section: Section64?, lazySymbolTableList: [LazySymbolEntryModel] ) {
        self.dataSlice = dataSlice
        self.componentTitle = section?.segname
        self.componentSubTitle = section?.sectname
        self.section = section
        self.lazySymbolTableList = lazySymbolTableList
        self.typeTitle = "Section"
    }
    
}
