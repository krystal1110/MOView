//
//  IndsymComponent.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/23.
//

import Foundation
 
/*
   存储着间接符号表信息
*/

//struct IndsymComponent:ComponentInfo{
//    var typeTitle: String?
//    var dataSlice: Data
//    var componentTitle: String?
//    var componentSubTitle: String?
//    var section: Section64?
//    let indirectSymbolTableList: [IndirectSymbolTableEntryModel]
//
//
//    init(_ dataSlice: Data, indirectSymbolTableList:[IndirectSymbolTableEntryModel] ) {
//        self.dataSlice = dataSlice
//        self.componentTitle = section?.segname
//        self.componentSubTitle = section?.sectname
//        self.indirectSymbolTableList = indirectSymbolTableList
//        self.typeTitle = "Indirect Symbol Table"
//    }
//
//}
 
public class IndsymModule:MachoModule{
    
    var indirectSymTab : [IndirectSymbolTableEntryModel]
    
    init(with dataSlice: Data ,
         indirectSymTab:[IndirectSymbolTableEntryModel]) {
         
        self.indirectSymTab = indirectSymTab
        var translateItems:[[ExplanationItem]]  = []
        let list = indirectSymTab.compactMap{$0.explanationItem}
        translateItems.append(list)
        super.init(with: dataSlice, translateItems: translateItems,moduleTitle: "__LINKEDIT",moduleSubTitle: "Indirect Symbol Table")
        
        
    }
}

