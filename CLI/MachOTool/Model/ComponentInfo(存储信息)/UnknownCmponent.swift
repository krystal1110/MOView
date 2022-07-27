//
//  UnknownCmponent.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/27.
//

import Foundation


public struct UnknownCmponent: ComponentInfo{
    public var dataSlice: Data
    public var componentTitle: String?
    public var componentSubTitle: String?
    public var section: Section64?
    
    init(_ dataSlice: Data, section: Section64?  ) {
        self.dataSlice = dataSlice
        self.componentTitle = section?.segname
        self.componentSubTitle = section?.sectname
        self.section = section
    }
    
}
