//
//  HeaderModule.swift
//  MachOTool
//
//  Created by karthrine on 2022/8/11.
//

import Foundation

 
public class HeaderModule:MachoModule{
    
    init(with dataSlice: Data ,
         header:MachOHeader) {
        var translateItems:[[ExplanationItem]]  = []
        translateItems.append(header.displayStore.items)
        let subTitle = MachoType(with: header.filetype).name
        let extraTitle = header.cpuTypeString
        super.init(with: header.displayStore.dataSlice, translateItems: translateItems,moduleTitle:"Macho Header" ,moduleSubTitle: subTitle, moduleExtraTitle: extraTitle)
    }
}
