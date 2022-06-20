//
//  ClassRefsStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/10.
//

import Foundation

class ClassRefsStoreInfo: BaseStoreInfo {
    let classRefsPointerList: [ReferencesPointer]

    init(with dataSlice: Data,
         is64Bit: Bool,
         title: String,
         subTitle: String? = nil,
         sectionVirtualAddress: UInt64,
         classRefsPointerList: [ReferencesPointer]) {
        self.classRefsPointerList = classRefsPointerList
        super.init(with: dataSlice, title: title, subTitle: subTitle, sectionVirtualAddress: sectionVirtualAddress)
    }
}
 
