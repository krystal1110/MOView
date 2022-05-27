//
//  LazySymbolEntryModel.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/25.
//

import Foundation

struct LazySymbolEntryModel: MachoExplainModel {
    
    static func modelSize(is64Bit: Bool) -> Int {
        return is64Bit ? 8 : 4
    }

    let startOffset:Int
    let startOffsetHex:String
    var explanationItem: ExplanationItem? = nil
    
    init(with data: DataSlice, is64Bit: Bool) {
        self.startOffset = data.startOffset
        self.startOffsetHex = self.startOffset.hex
    }

}
