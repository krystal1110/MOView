//
//  ObjcPointer64EnterModel.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/28.
//

import Foundation


struct ObjcPointer64EnterModel: MachoExplainModel {
    
    static func modelSize(is64Bit: Bool) -> Int {
        return is64Bit ? 8 : 4
    }

    var explanationItem: ExplanationItem? = nil
    var data:DataSlice
    init(with data: DataSlice, is64Bit: Bool) {

        self.data = data
    }

}
