//
//  ReferencesStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/30.
//

import Foundation

class ReferencesStoreInfo: BaseStoreInfo {
    let referencesPointerList: [ReferencesPointer]

    init(with dataSlice: Data,
         is64Bit: Bool,
         title: String,
         subTitle: String? = nil,
         sectionVirtualAddress: UInt64,
         referencesPointerList: [ReferencesPointer]) {
        self.referencesPointerList = referencesPointerList
        super.init(with: dataSlice, title: title, subTitle: subTitle, sectionVirtualAddress: sectionVirtualAddress)
    }
}
 
