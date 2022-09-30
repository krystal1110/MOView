//
//  RebaseInfoInterpreter.swift
//  mocha (macOS)
//
//  Created by white on 2022/1/9.
//

import Foundation

struct OperationCodeContainer<Code: OperationCodeProtocol> {
    
    let operationCodes: [OperationCode<Code>]
    let numberOfAccumulatedTransItems: [Int]
    let numberOfTransItemsTotal: Int
    
    init(operationCodes: [OperationCode<Code>]) {
        self.operationCodes = operationCodes
        var numberOfAccumulatedTransItems = [Int].init(repeating: 0, count: operationCodes.count)
        for (index, operationCode) in operationCodes.enumerated() {
            let accumulated = index == 0 ? 0 : numberOfAccumulatedTransItems[index - 1]
            numberOfAccumulatedTransItems[index] = accumulated + operationCode.numberOfTranslationItems
        }
        self.numberOfAccumulatedTransItems = numberOfAccumulatedTransItems
        self.numberOfTransItemsTotal = numberOfAccumulatedTransItems.last!
    }
}

class OperationCodeInterpreter<Code: OperationCodeProtocol>: Interpreter {
    var dataSlice: Data
    
    var section: Section64?
    
    var searchProtocol: SearchProtocol
    
    init(with  dataSlice: Data, section:Section64?,  searchProtocol:SearchProtocol){
        self.dataSlice = dataSlice
        self.section = section
        self.searchProtocol = searchProtocol
    }
//    override var shouldPreload: Bool { true }
//
//    override func generatePayload() -> OperationCodeContainer<Code> {
//        return OperationCodeInterpreter.operationCodes(from: self.data)
//    }
//
//    override func numberOfTranslationSections() -> Int {
//        return self.payload.numberOfTransItemsTotal
//    }
//
//    override func numberOfTranslationItems(at section: Int) -> Int {
//        return 1
//    }
    
//    func translationItem(at index:Int) -> ExplanationItem {
//
//        for element in self.payload.numberOfAccumulatedTransItems.enumerated() {
//            let operationCode = self.payload.operationCodes[element.offset]
//            if index < element.element {
//                let numberOfTransItemsBeforeCurrent = element.element - operationCode.numberOfTranslationItems
//                return operationCode.translationItems[index - numberOfTransItemsBeforeCurrent]
//            }
//        }
//    }
    
    // parsing
     func operationCodes() -> OperationCodeContainer<Code> {
        
        var operationCodes: [OperationCode<Code>] = []
        var index: Int = 0
        let rawData = self.dataSlice
        while index < rawData.count {
            let startIndexOfCurrentOperation = index
            let byte = rawData[rawData.startIndex+index]; index += 1
            let operationCodeValue = byte & 0xf0 // mask the most significant 4 bits
            let immediateValue = byte & 0x0f // mask the least significant 4 bits
            let operationCode = Code.init(operationCodeValue: operationCodeValue, immediateValue: immediateValue)
            
            // trailing LEBs
            var lebValues: [DyldInfoLEB] = []
            for _ in 0..<operationCode.numberOfTrailingLEB {
                let ulebStartIndex = index
                var delta: Swift.UInt64 = 0
                var shift: Swift.UInt32 = 0
                var more = true
                repeat {
                    let lebByte = rawData[rawData.startIndex+index]; index += 1
                    delta |= ((Swift.UInt64(lebByte) & 0x7f) << shift)
                    shift += 7
                    if lebByte < 0x80 {
                        more = false
                    }
                } while (more)
                
                let isSigned = operationCode.trailingLEBType == .signed
                if (isSigned) {
                    let signExtendMask: Swift.UInt64 = ~0
                    delta |= signExtendMask << shift
                }
                
                lebValues.append(DyldInfoLEB(absoluteRange:(rawData.startIndex+ulebStartIndex)..<(rawData.startIndex+index), raw: delta, isSigned: isSigned))
            }
            
            // trailing string
            var cstringData: Data? = nil
            if operationCode.hasTrailingCString {
                let cstringStartIndex = index
                while (rawData[rawData.startIndex+index] != 0) {
                    index += 1
                }
                index += 1 // the final \0 is a part of the string
                cstringData = rawData[rawData.startIndex+cstringStartIndex..<rawData.startIndex+index]
            }
            
            operationCodes.append(OperationCode<Code>(absoluteOffset:rawData.startIndex+startIndexOfCurrentOperation,
                                                      operationCode: operationCode,
                                                      lebValues: lebValues,
                                                      cstringData: cstringData))
        }
        
        return OperationCodeContainer(operationCodes: operationCodes)
    }
}
