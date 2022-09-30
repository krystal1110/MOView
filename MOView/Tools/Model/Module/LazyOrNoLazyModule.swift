//
//  LazySymbolStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/26.
//

import Foundation

 class LazyOrNoLazyModule:MachoModule{
    
    var pointers : [LazySymbolEntryModel]
    
    init(with dataSlice: Data ,
         section:Section64,
         pointers:[LazySymbolEntryModel]) {
         
        self.pointers = pointers
        var translateItems:[[ExplanationItem]]  = []
        let list = pointers.compactMap{$0.explanationItem}
        translateItems.append(list)
        let subTitle = "\(section.segname),\(section.sectname)"
        super.init(with: dataSlice, translateItems: translateItems,moduleTitle: "Section",moduleSubTitle: subTitle)
    }
}
