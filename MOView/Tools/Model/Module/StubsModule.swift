//
//  StubsModule.swift
//  MachOTool
//
//  Created by karthrine on 2022/8/16.
//

import Foundation

 class StubsModule:MachoModule{
    
    var pointers : [StubsPointer]
    
    init(with dataSlice: Data ,
         section:Section64,
         pointers:[StubsPointer]) {
         
        self.pointers = pointers
        var translateItems:[[ExplanationItem]]  = []
        let list = pointers.compactMap{$0.explanationItem}
        translateItems.append(list)
        let subTitle = "\(section.segname),\(section.sectname)"
        super.init(with: dataSlice, translateItems: translateItems,moduleTitle: "Section",moduleSubTitle: subTitle)
    }
}
