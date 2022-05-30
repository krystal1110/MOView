//
//  ReferencesStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/30.
//

import Foundation

class ReferencesStoreInfo: BaseStoreInfo {
    let dataSlice: DataSlice
    let referencesPointerList: [ReferencesPointer]
    var componentTitle: String { title }
    var componentSubTitle: String? { subTitle }
    let title: String
    let subTitle: String?

    init(with dataSlice: DataSlice,
         is64Bit: Bool,
         referencesPointerList: [ReferencesPointer],
         title: String,
         subTitle: String? = nil) {
        self.referencesPointerList = referencesPointerList
        self.title = title
        self.subTitle = subTitle
        self.dataSlice = dataSlice
    }
}
 
