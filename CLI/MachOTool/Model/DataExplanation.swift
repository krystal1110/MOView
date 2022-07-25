//
//  JYDataExplanation.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/15.
//

import Foundation

// 解释model
public struct ExplanationModel {
    public let description: String? // 描述
    public let explanation: String // 解释
    public let extraDescription: String?
    public let extraExplanation: String?

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
public struct ExplanationItem {
    public var sourceDataRange: Range<Int>?
    public let model: ExplanationModel

    init(sourceDataRange: Range<Int>?, model: ExplanationModel) {
        self.sourceDataRange = sourceDataRange
        self.model = model
    }
}
