//
//  StringTabModule.swift
//  MachoTool
//
//  Created by karthrine on 2022/8/10.
//

import Foundation


 

 class StringTabModule:MachoModule{
    
    var stringTab : [StringPosition]
    
    init(with dataSlice: Data ,
        stringTab:[StringPosition]) {
        self.stringTab = stringTab
        var translateItems:[[ExplanationItem]]  = []
        let list = stringTab.compactMap{$0.explanationItem}
        translateItems.append(list)
        super.init(with: dataSlice, translateItems: translateItems,moduleTitle: "__LINKEDIT",moduleSubTitle: "String Table")
    }
}
