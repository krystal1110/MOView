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
    let dataSlice: DataSlice
    let interpreter: StringInterpreter
    let stringTableList: [StringPosition]
    var componentTitle: String { title }
    var componentSubTitle: String? { subTitle }
    let title: String
    let subTitle: String?

    init(with dataSlice: DataSlice,
         is64Bit: Bool,
         interpreter: StringInterpreter,
         stringTableList: [StringPosition],
         title: String,
         subTitle: String? = nil) {
        self.interpreter = interpreter
        self.stringTableList = stringTableList
        self.title = title
        self.subTitle = subTitle
        self.dataSlice = dataSlice
    }
}
