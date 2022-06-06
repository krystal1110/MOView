//
//  UnusedScanManager.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/2.
//

import Foundation


class UnusedScanManager {
    
    var macho:Macho
//    var classRef
    
    init(with macho:Macho) {
        self.macho = macho
        
        
        for baseStoreInfo in self.macho.allBaseStoreInfoList {
            if (baseStoreInfo.componentSubTitle == "__DATA,__objc_classlist") {
                
            }else if (baseStoreInfo.componentSubTitle == "__DATA,__objc_classlist"){
                
            }
        }
        
        
        
    }
    
}
