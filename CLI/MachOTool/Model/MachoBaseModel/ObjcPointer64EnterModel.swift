//
//  ObjcPointer64EnterModel.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/28.
//

import Foundation


struct ObjcPointer64EnterModel {
    
    var explanationItem: ExplanationItem? = nil
    var data:Data
    init(with data: Data, is64Bit: Bool) {

        self.data = data
    }

}
