//
//  UStringStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/31.
//

import Foundation

 

struct UStringComponent: ComponentInfo{
    var typeTitle: String?
    var dataSlice: Data
    var componentTitle: String?
    var componentSubTitle: String?
    var section: Section64?
    var uStringList : [UStringPosition]
    
    init(_ dataSlice: Data, section: Section64?, uStringList: [UStringPosition] ) {
        self.dataSlice = dataSlice
        self.componentTitle = section?.segname
        self.componentSubTitle = section?.sectname
        self.section = section
        self.uStringList = uStringList
        self.typeTitle = "Section"
    }
    
}
