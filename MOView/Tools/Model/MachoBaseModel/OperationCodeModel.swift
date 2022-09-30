//
//  OperationCodeModel.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/8.
//

import Foundation


class OperationCodeModel {
    
    let absoluteOffset: Int
    let operationCode: BindOperationCode
    let lebValues: [DyldInfoLEB]
    let cstringData: Data?

    lazy var translationItems: [ExplanationItem] = {
        
        var translationItems: [ExplanationItem] = []
        
        let byteIndexNextOfOperationCode = absoluteOffset+1
         
        translationItems.append(ExplanationItem(sourceDataRange: absoluteOffset..<byteIndexNextOfOperationCode,
                                                model: ExplanationModel(description: "Operation Code (Upper 4 bits)",
                                                                        explanation: operationCode.bindOperationType.readable)))
        
        translationItems.append(ExplanationItem(sourceDataRange: absoluteOffset..<byteIndexNextOfOperationCode,
                                                model: ExplanationModel(description: "Immediate Value Used As (Lower 4 bits)",
                                                                        explanation: operationCode.bindImmediateType.readable)))
        
        translationItems.append(contentsOf: lebValues.map { ulebValue in
            ExplanationItem(sourceDataRange: ulebValue.absoluteRange,
                            model: ExplanationModel(description: "LEB Value",
                                                            explanation: ulebValue.isSigned ? "\(Int(bitPattern: UInt(ulebValue.raw)))" : "\(ulebValue.raw)"))
        })
        
        if let cStringData = cstringData {
            let cstring = cStringData.utf8String ?? "🙅‍♂️ Invalid CString"
            translationItems.append(ExplanationItem(sourceDataRange: byteIndexNextOfOperationCode..<(byteIndexNextOfOperationCode + cStringData.count),
                                                    model: ExplanationModel(description: "String", explanation: cstring)))
        }
        
        let value = translationValue()
        return translationItems
    }()
    
    init(absoluteOffset: Int, operationCode: BindOperationCode, lebValues:[DyldInfoLEB], cstringData: Data?) {
        self.absoluteOffset = absoluteOffset
        self.operationCode = operationCode
        self.lebValues = lebValues
        self.cstringData = cstringData
//        self.numberOfTranslationItems = 2 + lebValues.count + (cstringData == nil ? 0 : 1)
         
    }
    
    
    func translationValue() -> String? {
        if operationCode.bindOperationType == .setDylibOrdinalImm {
            let value = "dylib (\(operationCode.bindImmediateType.readable))"
            return value
        }else if operationCode.bindOperationType == .setSymbolTrailingFlagsImm {
            let value = "Symbol Name(\(cstringData?.utf8String ?? "🙅‍♂️ Invalid CString"))"
            return value
        }else if operationCode.bindOperationType == .setSegmentAndOffsetULEB {
            let value = "segment (\(operationCode.bindImmediateType.readable)) \noffset (\(Int(bitPattern: UInt(lebValues.first?.raw ?? 0))))"
//            let value = "offset (\(Int(bitPattern: UInt(lebValues.first?.raw ?? 0))))"
            return value
        }else if operationCode.bindOperationType == .doBind {
            return "------dobing--------"
        }else if operationCode.bindOperationType == .addAddrULEB {
            let value = "offset (\(Int(bitPattern: UInt(lebValues.first?.raw ?? 0))))"
            return value
        }else if operationCode.bindOperationType == .setTypeImm {
            let value = "Type (\(operationCode.bindImmediateType.readable))"
            return value
        }else if operationCode.bindOperationType == .doBindAddAddrULEB {
            let value =  "BIND_OPCODE_DO_BIND_ADD_ADDR_ULEB  offset (\(Int(bitPattern: UInt(lebValues.first?.raw ?? 0))))"
            return value
        }else if operationCode.bindOperationType == .doBindULEBTimesSkippingULEB {
            
            if lebValues.count == 2 {
                let value = "count (\(Int(bitPattern: UInt(lebValues.first?.raw ?? 0))))  skip (\(Int(bitPattern: UInt(lebValues[1].raw ))))"
                return value
            }
            
            return nil
        }else if operationCode.bindOperationType == .doBindAddAddrImmScaled {
            let value = "Scale (\(operationCode.bindImmediateType.readable))"
            return value
        }
        return nil
    }
    
 
     
}
