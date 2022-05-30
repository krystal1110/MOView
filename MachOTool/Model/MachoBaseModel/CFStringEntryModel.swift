//
//  CFStringEntryModel.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/27.
//

import Foundation

struct CFStringEntryModel: MachoExplainModel {
    
    static func modelSize(is64Bit: Bool) -> Int {
        return is64Bit ? 32 : 4
    }

    var explanationItem: ExplanationItem? = nil
    var data:DataSlice
    init(with data: DataSlice, is64Bit: Bool) {

        self.data = data
    }

}
