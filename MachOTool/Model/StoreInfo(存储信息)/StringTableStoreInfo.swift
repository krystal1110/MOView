//
//  StringTableStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/21.
//

import Foundation

/*
   字符串表解释器
   里面存着字符串表的信息
   interpreter -> 字符串表数组 里面存放着所有的符号模型(StringPosition)
 */
class StringTableStoreInfo: BaseStoreInfo {
    let interpreter: StringInterpreter
    let stringTableList: [StringPosition]
    
    init(with dataSlice: Data,
         is64Bit: Bool,
         interpreter: StringInterpreter,
         title: String,
         subTitle: String? = nil,
         sectionVirtualAddress: UInt64?,
         stringTableList: [StringPosition]) {
        self.interpreter = interpreter
        self.stringTableList = stringTableList
        super.init(with: dataSlice, title: title, subTitle: subTitle, sectionVirtualAddress: sectionVirtualAddress)
    }
}
