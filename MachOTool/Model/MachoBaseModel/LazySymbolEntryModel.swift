//
//  LazySymbolEntryModel.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/25.
//

import Foundation

struct LazySymbolEntryModel {
    
  

    let startOffset:Int
    var explanationItem: ExplanationItem? = nil
    
    init(with data: Data) {
        self.startOffset = data.startIndex
    }

}
