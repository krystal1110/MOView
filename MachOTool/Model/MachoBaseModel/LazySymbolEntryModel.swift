//
//  LazySymbolEntryModel.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/25.
//

import Foundation

struct LazySymbolEntryModel: MachoExplainModel {
    
    static func modelSize( ) -> Int {
        return 8
    }

    let startOffset:Int
    var explanationItem: ExplanationItem? = nil
    
    init(with data: Data, is64Bit: Bool) {
        self.startOffset = data.startIndex
    }

}
