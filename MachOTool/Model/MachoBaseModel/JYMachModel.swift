//
//  JYMachModel.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/17.
//

import Foundation


protocol MachoExplainModel{
    
    // init
    init(with data:DataSlice, is64Bit: Bool)
   
    // model的大小
    static func modelSize(is64Bit: Bool)-> Int
    
    // 有多少条数据模型
    static func numberOfExplanationItem()-> Int
}

class MachoModel<Model :MachoExplainModel> {
    
    // 生成容器
    func generateVessel(data:DataSlice, is64Bit: Bool) -> [Model] {
        let modelSize = Model.modelSize(is64Bit: is64Bit)
        let numberOfModels =  data.count / modelSize
        var models: [Model] = []
        for index in 0..<numberOfModels {
            let modelSize = Model.modelSize(is64Bit: is64Bit)
            
            let startIndex = index * modelSize
            let modelData = data.interception(from: startIndex, length: modelSize)
            
            let model = Model(with: modelData, is64Bit: is64Bit)
            models.append(model)
        }
        return models
    }
    
}
 
 
