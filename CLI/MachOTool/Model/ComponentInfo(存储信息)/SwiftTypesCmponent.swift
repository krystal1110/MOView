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
    var swiftTypesList : [SwiftTypeModel]
    var swiftRefsSet:Set<String>
    var accessFuncDic: Dictionary<String,UInt64>
    
    init(_ dataSlice: Data, section: Section64?, swiftTypesList: [SwiftTypeModel] ,swiftRefsSet:Set<String>, accessFuncDic: Dictionary<String,UInt64>) {
        self.dataSlice = dataSlice
        self.componentTitle = section?.segname
        self.componentSubTitle = section?.sectname
        self.section = section
        self.swiftTypesList = swiftTypesList
        self.swiftRefsSet = swiftRefsSet
        self.accessFuncDic = accessFuncDic
    }
    
}
