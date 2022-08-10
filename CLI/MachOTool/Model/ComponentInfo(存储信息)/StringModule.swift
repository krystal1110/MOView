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
 __TEXT,__cstring    __TEXT,__objc_classname   __TEXT,__objc_methtype 均会来到此处
 */
 


//public struct StringComponent: ComponentInfo{
//    public var typeTitle: String?
//    public var dataSlice: Data
//    public var componentTitle: String?
//    public var componentSubTitle: String?
//    public var section: Section64?
//    public var stringList : [StringPosition]
//
//    init(_ dataSlice: Data, section: Section64?, stringList: [StringPosition] ) {
//        self.dataSlice = dataSlice
//        self.componentTitle = section?.segname
//        self.componentSubTitle = section?.sectname
//        self.section = section
//        self.stringList = stringList
//        if let _ = section {
//            self.typeTitle = "Section"
//        }else{
//            self.typeTitle = "String Table"
//            self.componentTitle =  "__LINKEDIT"
//            self.componentSubTitle =  ""
//
//        }
//    }
//
//}


public class StringModule:MachoModule{
    
    var stringList : [StringPosition]
    
    init(with dataSlice: Data ,
         section:Section64,
         stringList:[StringPosition]) {
         
        self.stringList = stringList
        var translateItems:[[ExplanationItem]]  = []
        let list = stringList.compactMap{$0.explanationItem}
        translateItems.append(list)
        let subTitle = "\(section.segname),\(section.sectname)"
        super.init(with: dataSlice, translateItems: translateItems,moduleTitle: "Section",moduleSubTitle: subTitle)
    }
}
