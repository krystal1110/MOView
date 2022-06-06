//
//  CFStringStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/1.
//

import Foundation

class CFStringStoreInfo: BaseStoreInfo {
    
    let objcCFStringList: [ObjcCFString]

    init(with dataSlice: Data,
         is64Bit: Bool,
         title: String,
         subTitle: String? = nil,
         sectionVirtualAddress: UInt64,
         objcCFStringList: [ObjcCFString]) {
        self.objcCFStringList = objcCFStringList
        super.init(with: dataSlice, title: title, subTitle: subTitle, sectionVirtualAddress: sectionVirtualAddress)
    }
}
 
