//
//  UnknownCmponent.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/27.
//

import Foundation


struct UnknownCmponent: ComponentInfo{
    var dataSlice: Data
    var componentTitle: String?
    var componentSubTitle: String?
    var section: Section64?
    
    init(_ dataSlice: Data, section: Section64?  ) {
        self.dataSlice = dataSlice
        self.componentTitle = section?.segname
        self.componentSubTitle = section?.sectname
        self.section = section
    }
    
}
