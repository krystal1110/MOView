//
//  CFStringComponent.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/1.
//

import Foundation

 

struct CFStringComponent: ComponentInfo{
    var typeTitle: String?
    var dataSlice: Data
    var componentTitle: String?
    var componentSubTitle: String?
    var section: Section64?
    var objcCFStringList : [ObjcCFString]
    
    init(_ dataSlice: Data, section: Section64?, objcCFStringList: [ObjcCFString] ) {
        self.dataSlice = dataSlice
        self.componentTitle = section?.segname
        self.componentSubTitle = section?.sectname
        self.section = section
        self.objcCFStringList = objcCFStringList
        self.typeTitle = "Section"
    }
    
}
