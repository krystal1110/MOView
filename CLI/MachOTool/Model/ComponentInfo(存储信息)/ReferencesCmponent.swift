//
//  ReferencesStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/30.
//

import Foundation

 
 

struct ReferencesCmponent: ComponentInfo{
    var dataSlice: Data
    var componentTitle: String?
    var componentSubTitle: String?
    var section: Section64?
    var referencesPtrList : [ReferencesPointer]
    
    init(_ dataSlice: Data, section: Section64?, referencesPtrList: [ReferencesPointer] ) {
        self.dataSlice = dataSlice
        self.componentTitle = section?.segname
        self.componentSubTitle = section?.sectname
        self.section = section
        self.referencesPtrList = referencesPtrList
    }
    
}



 

 
 
