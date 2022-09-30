//
//  StringTableStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/21.
//

import Foundation

class StringModule:MachoModule{
    
    var stringList : [StringPosition]
    
    init(with dataSlice: Data ,
         section:Section64,
         stringList:[StringPosition]) {
         
        self.stringList = stringList
        var translateItems:[[ExplanationItem]]  = []
        let list = stringList.compactMap{$0.explanationItem}
        translateItems.append(list)
        let subTitle = "\(section.segname),\(section.sectname)"
        super.init(with: dataSlice, translateItems: translateItems,moduleTitle: "Section",moduleSubTitle: subTitle)
    }
}
