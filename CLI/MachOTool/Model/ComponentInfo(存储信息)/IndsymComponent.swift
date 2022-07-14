//
//  IndsymComponent.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/23.
//

import Foundation
 
/*
   存储着间接符号表信息
*/

struct IndsymComponent:ComponentInfo{
     
    
    var dataSlice: Data
    var componentTitle: String?
    var componentSubTitle: String?
    var section: Section64?
    let indirectSymbolTableList: [IndirectSymbolTableEntryModel]
    
    
    init(_ dataSlice: Data, indirectSymbolTableList:[IndirectSymbolTableEntryModel] ) {
        self.dataSlice = dataSlice
        self.componentTitle = section?.segname
        self.componentSubTitle = section?.sectname
        self.indirectSymbolTableList = indirectSymbolTableList
    }
    
}
 
