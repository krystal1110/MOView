//
//  SymbolTableStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/21.
//

import Foundation

/*
   符号表存储器
   里面存着符号表的信息
   interpreter -> 符号表数组 里面存放着所有的符号模型(SymbolTableEntryModel)
 */
 

public class SymbolTableModule:MachoModule{
    
    public var symbolTableList : [SymbolTableModel]
    
    init(with dataSlice: Data ,symbolTableList:[SymbolTableModel]) {
         
        self.symbolTableList = symbolTableList
        var translateItems:[[ExplanationItem]]  = []
        for item in symbolTableList{
            translateItems.append(item.translaitonItems)
        }
        super.init(with: dataSlice, translateItems: translateItems,moduleTitle: "__LINKEDIT",moduleSubTitle: "Symbol Table")
    }
    
    public override func lazyConvertExplanation(at section:Int) {
        
        
        let value = self.lazyIdentifier[section] ?? false
        if value {return}
        self.lazyIdentifier.updateValue(true, forKey: section)
        let model:SymbolTableModel = self.symbolTableList[section]
        let item = model.findSymbolNameItem()
        self.translateItems[section].append(item)
    }
    
    
}

