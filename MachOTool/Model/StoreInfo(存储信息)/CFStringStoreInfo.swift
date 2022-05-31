//
//  CFStringStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/1.
//

import Foundation

class CFStringStoreInfo: BaseStoreInfo {
    let dataSlice: DataSlice
    let objcCFStringList: [ObjcCFString]
    var componentTitle: String { title }
    var componentSubTitle: String? { subTitle }
    let title: String
    let subTitle: String?

    init(with dataSlice: DataSlice,
         is64Bit: Bool,
         objcCFStringList: [ObjcCFString],
         title: String,
         subTitle: String? = nil) {
        self.objcCFStringList = objcCFStringList
        self.title = title
        self.subTitle = subTitle
        self.dataSlice = dataSlice
    }
}
 
