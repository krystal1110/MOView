//
//  CFStringComponent.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/1.
//

import Foundation

 

//struct CFStringComponent: ComponentInfo{
//    var typeTitle: String?
//    var dataSlice: Data
//    var componentTitle: String?
//    var componentSubTitle: String?
//    var section: Section64?
//    var objcCFStringList : [ObjcCFString]
//
//    init(_ dataSlice: Data, section: Section64?, objcCFStringList: [ObjcCFString] ) {
//        self.dataSlice = dataSlice
//        self.componentTitle = section?.segname
//        self.componentSubTitle = section?.sectname
//        self.section = section
//        self.objcCFStringList = objcCFStringList
//        self.typeTitle = "Section"
//    }
//
//}

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
