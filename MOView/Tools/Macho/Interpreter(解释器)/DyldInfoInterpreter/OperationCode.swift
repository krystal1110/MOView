//
//  OperationCode.swift
//  mocha (macOS)
//
//  Created by white on 2022/1/13.
//

import Foundation

enum LEBType {
    case signed
    case unsigned
}

protocol OperationCodeProtocol {
    init(operationCodeValue: UInt8, immediateValue: UInt8)
    func operationReadable() -> String
    func immediateReadable() -> String
    
    var numberOfTrailingLEB: Int { get }
    var trailingLEBType: LEBType { get }
    var hasTrailingCString: Bool { get }
}

struct DyldInfoLEB {
    let absoluteRange: Range<Int>
    let raw: UInt64
    let isSigned: Bool
}

class OperationCode<Code: OperationCodeProtocol> {
    
    let absoluteOffset: Int
    let operationCode: OperationCodeProtocol
    let lebValues: [DyldInfoLEB]
    let cstringData: Data?
    let numberOfTranslationItems: Int
    
    lazy var translationItems: [ExplanationItem] = {
        
        var translationItems: [ExplanationItem] = []
        
        let byteIndexNextOfOperationCode = absoluteOffset+1
         
        translationItems.append(ExplanationItem(sourceDataRange: absoluteOffset..<byteIndexNextOfOperationCode,
                                                model: ExplanationModel(description: "Operation Code (Upper 4 bits)",
                                                                                explanation: operationCode.operationReadable())))
        
        translationItems.append(ExplanationItem(sourceDataRange: absoluteOffset..<byteIndexNextOfOperationCode,
                                                model: ExplanationModel(description: "Immediate Value Used As (Lower 4 bits)",
                                                                                explanation: operationCode.immediateReadable())))
        
        translationItems.append(contentsOf: lebValues.map { ulebValue in
            ExplanationItem(sourceDataRange: ulebValue.absoluteRange,
                            model: ExplanationModel(description: "LEB Value",
                                                            explanation: ulebValue.isSigned ? "\(Int(bitPattern: UInt(ulebValue.raw)))" : "\(ulebValue.raw)"))
        })
        
        if let cstringData = cstringData {
            let cstring = cstringData.utf8String ?? "🙅‍♂️ Invalid CString"
            translationItems.append(ExplanationItem(sourceDataRange: byteIndexNextOfOperationCode..<(byteIndexNextOfOperationCode+cstringData.count),
                                                    model: ExplanationModel(description: "String", explanation: cstring )))
        }
        
        return translationItems
    }()
    
    init(absoluteOffset: Int, operationCode: Code, lebValues:[DyldInfoLEB], cstringData: Data?) {
        self.absoluteOffset = absoluteOffset
        self.operationCode = operationCode
        self.lebValues = lebValues
        self.cstringData = cstringData
        self.numberOfTranslationItems = 2 + lebValues.count + (cstringData == nil ? 0 : 1)
    }
}
