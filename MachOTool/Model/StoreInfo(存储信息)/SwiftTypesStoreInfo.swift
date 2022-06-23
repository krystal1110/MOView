//
//  SwiftTypesStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/22.
//

import Foundation

class SwiftTypesStoreInfo: BaseStoreInfo {
    
    let swiftTypesObjList: [SwiftNominalModel]

    init(with dataSlice: Data,
         is64Bit: Bool,
         title: String,
         subTitle: String? = nil,
         sectionVirtualAddress: UInt64,
         swiftTypesObjList: [SwiftNominalModel]) {
        self.swiftTypesObjList = swiftTypesObjList
        super.init(with: dataSlice, title: title, subTitle: subTitle, sectionVirtualAddress: sectionVirtualAddress)
    }
}
