//
//  CFStringComponent.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/1.
//

import Foundation

 

 class CFStringModule:MachoModule{
    
    var pointers : [ObjcCFString]
    
    init(with dataSlice: Data ,
         section:Section64,
         pointers:[ObjcCFString]) {
         
        self.pointers = pointers
        var translateItems:[[ExplanationItem]]  = []
        for item in pointers{
            translateItems.append(item.explanationItems)
        }
        let subTitle = "\(section.segname),\(section.sectname)"
        super.init(with: dataSlice, translateItems: translateItems,moduleTitle: "Section",moduleSubTitle: subTitle)
    }
}
