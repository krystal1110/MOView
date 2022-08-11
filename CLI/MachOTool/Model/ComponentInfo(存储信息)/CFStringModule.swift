//
//  CFStringComponent.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/1.
//

import Foundation

 

public class CFStringModule:MachoModule{
    
    var pointers : [ObjcCFString]
    
    init(with dataSlice: Data ,
         section:Section64,
         pointers:[ObjcCFString]) {
         
        self.pointers = pointers
        var translateItems:[[ExplanationItem]]  = []
        let list = pointers.compactMap{$0.explanationItem}
        translateItems.append(list)
        let subTitle = "\(section.segname),\(section.sectname)"
        super.init(with: dataSlice, translateItems: translateItems,moduleTitle: "Section",moduleSubTitle: subTitle)
    }
}
