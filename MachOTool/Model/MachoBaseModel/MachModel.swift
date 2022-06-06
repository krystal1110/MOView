//
//  MachModel.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/17.
//

import Foundation

protocol MachoExplainModel {
    // init
    init(with data: Data, is64Bit: Bool)

    // model的大小
    static func modelSize() -> Int
}

class MachoModel<Model: MachoExplainModel> {
    // 生成容器
    func generateVessel(data: Data, is64Bit: Bool) -> [Model] {
        let modelSize = Model.modelSize()
        let numberOfModels = data.count / modelSize
        var models: [Model] = []
        for index in 0 ..< numberOfModels {
            let modelSize = Model.modelSize()

            let startIndex = index * modelSize
            let modelData = DataTool.interception(with: data, from: startIndex, length: modelSize)
            let model = Model(with: modelData, is64Bit: is64Bit)
            models.append(model)
        }
        return models
    }
}
