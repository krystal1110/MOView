//
//  ClassListComponent.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/30.
//

import Foundation
 

public class ClassListModule:MachoModule{
    
    var pointers : [ClassInfo]
    var classRefSet:Set<String>?
    var classNameSet:Set<String>?
    
    init(with dataSlice: Data ,
         section:Section64,
         pointers:[ClassInfo],
         classRefSet: Set<String>? = nil,
         classNameSet:Set<String>? = nil) {
        self.pointers = pointers
        self.classRefSet = classRefSet
        self.classNameSet = classNameSet
        var translateItems:[[ExplanationItem]]  = []
        for item in pointers{
            translateItems.append(item.explanationItems)
        }
        let subTitle = "\(section.segname),\(section.sectname)"
        super.init(with: dataSlice, translateItems: translateItems,moduleTitle: "Section",moduleSubTitle: subTitle)
    }
}
