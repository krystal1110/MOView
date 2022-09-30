//
//  UnknownCmponent.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/27.
//

import Foundation

 
 class UnknownModule:MachoModule{
    
    init(with dataSlice: Data ,
         section:Section64,
         list:[ExplanationItem]? = nil) {
        let subTitle = "\(section.segname),\(section.sectname)"
        
        var translateItems:[[ExplanationItem]]  = []
        translateItems.append(list ?? [])
        
        super.init(with: dataSlice, translateItems: translateItems,moduleTitle: "Section",moduleSubTitle: subTitle)
    }
}
