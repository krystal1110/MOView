//
//  ClassRefsComponent.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/10.
//

import Foundation
 

struct ClassRefsComponent: ComponentInfo{
    var dataSlice: Data
    var componentTitle: String?
    var componentSubTitle: String?
    var section: Section64?
    var classRefsPtrList : [ReferencesPointer]
    
    init(_ dataSlice: Data, section: Section64?, classRefsPtrList: [ReferencesPointer] ) {
        self.dataSlice = dataSlice
        self.componentTitle = section?.segname
        self.componentSubTitle = section?.sectname
        self.section = section
        self.classRefsPtrList = classRefsPtrList
    }
    
}
