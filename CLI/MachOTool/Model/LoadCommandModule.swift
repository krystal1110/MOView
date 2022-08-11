//
//  LoadCommandModule.swift
//  MachoTool
//
//  Created by karthrine on 2022/8/10.
//

import Foundation

public class LoadCommandModule:MachoModule{
    
    init(with dataSlice: Data ,
         displayStore:DisplayStore) {
        var translateItems:[[ExplanationItem]]  = []
        translateItems.append(displayStore.items)
        super.init(with: displayStore.dataSlice, translateItems: translateItems,moduleTitle:"Load Command" ,moduleSubTitle: displayStore.commandType, moduleExtraTitle: displayStore.commandSize)
    }
}
