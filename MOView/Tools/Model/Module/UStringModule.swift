//
//  UStringStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/31.
//

import Foundation

 

 

 class UStringModule:MachoModule{
    
    var pointers : [UStringPosition]
    
    init(with dataSlice: Data ,
         section:Section64,
         pointers:[UStringPosition]) {
         
        self.pointers = pointers
        var translateItems:[[ExplanationItem]]  = []
        let list = pointers.compactMap{$0.explanationItem}
        translateItems.append(list)
        let subTitle = "\(section.segname),\(section.sectname)"
        super.init(with: dataSlice, translateItems: translateItems,moduleTitle: "Section",moduleSubTitle: subTitle)
    }
}
