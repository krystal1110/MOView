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
 


struct StringComponent: ComponentInfo{
    var dataSlice: Data
    var componentTitle: String?
    var componentSubTitle: String?
    var section: Section64?
    var stringList : [StringPosition]
    
    init(_ dataSlice: Data, section: Section64?, stringList: [StringPosition] ) {
        self.dataSlice = dataSlice
        self.componentTitle = section?.segname
        self.componentSubTitle = section?.sectname
        self.section = section
        self.stringList = stringList
    }
    
}
