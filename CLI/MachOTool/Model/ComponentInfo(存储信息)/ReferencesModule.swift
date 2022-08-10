//
//  ReferencesStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/30.
//

import Foundation

 
 
 
  
public class ReferencesModule:MachoModule{
    
    var pointers : [ReferencesPointer]
    
    init(with dataSlice: Data ,
         section:Section64,
         pointers:[ReferencesPointer]) {
         
        self.pointers = pointers
        var translateItems:[[ExplanationItem]]  = []
        let list = pointers.compactMap{$0.explanationItem}
        translateItems.append(list)
        let subTitle = "\(section.segname),\(section.sectname)"
        super.init(with: dataSlice, translateItems: translateItems,moduleTitle: "Section",moduleSubTitle: subTitle)
    }
}


 

 
 
