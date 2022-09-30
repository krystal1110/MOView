//
//  LoadCommandModule.swift
//  MachoTool
//
//  Created by karthrine on 2022/8/10.
//

import Foundation

 class LoadCommandModule:MachoModule{
    
    init(with displayStore:DisplayStore) {
        super.init(with: displayStore.dataSlice, translateItems: displayStore.displayItems,moduleTitle:"Load Command" ,moduleSubTitle: displayStore.subTitle, moduleExtraTitle: displayStore.extra)
    }
}
