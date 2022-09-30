//
//  HeaderModule.swift
//  MachOTool
//
//  Created by karthrine on 2022/8/11.
//

import Foundation

 
 class HeaderModule:MachoModule{
    
    init(with dataSlice: Data ,
         header:MachOHeader) {
        let subTitle = MachoType(with: header.filetype).name
        let extraTitle = header.cpuTypeString
        super.init(with: header.displayStore.dataSlice, translateItems: header.displayStore.displayItems,moduleTitle:"Macho Header" ,moduleSubTitle: subTitle, moduleExtraTitle: extraTitle)
    }
}
