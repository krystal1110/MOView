//
//  MachoComponent.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/8.
//

import Foundation

class MachoComponent {
    let dataSlice: Data
    var componentSize: Int { dataSlice.count }
    init(_ dataSlice: Data) {
        self.dataSlice = dataSlice
    }
}
