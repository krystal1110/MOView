//
//  MachoComponent.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/8.
//

import Foundation

class MachoComponent {
    let dataSlice: DataSlice
    var componentSize: Int { dataSlice.count }
    init(_ dataSlice: DataSlice) {
        self.dataSlice = dataSlice
    }
}
