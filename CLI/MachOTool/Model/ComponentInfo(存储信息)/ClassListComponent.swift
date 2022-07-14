//
//  ClassListComponent.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/30.
//

import Foundation

struct ClassListCmponent: ComponentInfo{
    var dataSlice: Data
    var componentTitle: String?
    var componentSubTitle: String?
    var section: Section64?
    var classInfoList:[ClassInfo]
    
    var classRefSet:Set<String>?
    var classNameSet:Set<String>?

    
    
    init(_ dataSlice: Data, section: Section64?, classInfoList: [ClassInfo], classRefSet: Set<String>? = nil, classNameSet:Set<String>? = nil) {
        self.dataSlice = dataSlice
        self.componentTitle = section?.segname
        self.componentSubTitle = section?.sectname
        self.section = section
        self.classInfoList = classInfoList
        self.classRefSet = classRefSet
        self.classNameSet = classNameSet
        
    }
    
}
