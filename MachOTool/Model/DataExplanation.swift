//
//  JYDataExplanation.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/15.
//

import Foundation

// 解释model
struct ExplanationModel {
    let description: String? // 描述
    let explanation: String // 解释
    let extraDescription: String?
    let extraExplanation: String?

    init(description: String?,
         explanation: String,
         extraDescription: String? = nil,
         extraExplanation: String? = nil) {
        self.description = description
        self.explanation = explanation

        self.extraDescription = extraDescription
        self.extraExplanation = extraExplanation
    }
}

// 解释器
struct ExplanationItem {
    var sourceDataRange: Range<Int>?
    let model: ExplanationModel

    init(sourceDataRange: Range<Int>?, model: ExplanationModel) {
        self.sourceDataRange = sourceDataRange
        self.model = model
    }
}
