//
//  SwiftTypesStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/22.
//

import Foundation
 


struct SwiftTypesCmponent: ComponentInfo{
    var dataSlice: Data
    var componentTitle: String?
    var componentSubTitle: String?
    var section: Section64?
    var swiftTypesList : [SwiftNominalModel]
    
    init(_ dataSlice: Data, section: Section64?, swiftTypesList: [SwiftNominalModel] ) {
        self.dataSlice = dataSlice
        self.componentTitle = section?.segname
        self.componentSubTitle = section?.sectname
        self.section = section
        self.swiftTypesList = swiftTypesList
    }
    
}
