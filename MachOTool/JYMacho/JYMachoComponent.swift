//
//  JYMachoComponent.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/8.
//

import Foundation

class JYMachoComponent{
    let dataSlice: JYDataSlice
    var componentSize: Int { dataSlice.count }
    init(_ dataSlice: JYDataSlice) {
        self.dataSlice = dataSlice
    }
}
