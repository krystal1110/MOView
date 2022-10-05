//
//  IndirectSymbolTableInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/23.
//

import Foundation

 
struct IndirectSymbolTableInterpreter: Interpreter {
    
    var dataSlice: Data
    
    var section: Section64?
    
    var searchProtocol: SearchProtocol

    init(with  dataSlice: Data, section:Section64?,  searchProtocol:SearchProtocol){
        self.dataSlice = dataSlice
        self.section = section
        self.searchProtocol = searchProtocol
    }
    
    func transitionData() -> [IndirectSymbolTableEntryModel] {
 
        let modelSize = 4
        let numberOfModels = dataSlice.count / modelSize
        var models: [IndirectSymbolTableEntryModel] = []
        for index in 0 ..< numberOfModels {
            let startIndex = index * modelSize
            let modelData = DataTool.interception(with: dataSlice, from: startIndex, length: modelSize)
            var model = IndirectSymbolTableEntryModel(with: modelData)
            model.explanationItem = model.findSymbolName(searchProtocol: searchProtocol)
            models.append(model)
        }
        return models
    }
}


 
