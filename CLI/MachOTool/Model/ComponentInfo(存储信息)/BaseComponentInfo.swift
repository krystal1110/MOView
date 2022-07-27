//
//  BaseInterpretModel.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/22.
//

import Foundation

public class BaseStoreInfo {
    let dataSlice: Data
    var componentTitle: String { title }
    var componentSubTitle: String? { subTitle }
    var title: String
    let subTitle: String?
    let sectionVirtualAddress: UInt64?
   
    init(with dataSlice:Data, title:String, subTitle:String? = nil, sectionVirtualAddress: UInt64? = nil ) {
        self.title = title
        self.subTitle = subTitle
        self.dataSlice = dataSlice
        self.sectionVirtualAddress = sectionVirtualAddress
    }
    
}



public protocol ComponentInfo {
    var dataSlice: Data { get }
    var componentTitle: String? { get }
    var componentSubTitle: String? { get }
    var section:Section64? { set get }
}
