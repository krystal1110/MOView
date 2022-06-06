//
//  StringInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/18.
//

import Foundation

struct StringPosition {
    let startOffset: Int
    let virtualAddress: Swift.UInt64
    let length: Int
    var explanationItem: ExplanationItem? = nil
}

class StringInterpreter : BaseInterpreter {

    init(with dataSlice: Data, is64Bit: Bool, machoProtocol: MachoProtocol, sectionVirtualAddress:UInt64) {
        super.init(dataSlice, is64Bit: is64Bit, machoProtocol: machoProtocol, sectionVirtualAddress: sectionVirtualAddress)
    }

    func generatePayload() -> [StringPosition] {
        let rawData = self.data
        var cStringPositions: [StringPosition] = []
        var indexOfLastNull: Int? // index of last null char ( "\0" )

        for (indexOfCurNull, byte) in rawData.enumerated() {
            guard byte == 0 else { continue } // find null characters

            let lastIndex = indexOfLastNull ?? -1
            if indexOfCurNull - lastIndex == 1 {
                indexOfLastNull = indexOfCurNull // skip continuous \0
                continue
            }
            let nextCStringStartIndex = lastIndex + 1 // lastIdnex points to last null, ignore
            let nextCStringDataLength = indexOfCurNull - nextCStringStartIndex
            var cStringPosition = StringPosition(startOffset: nextCStringStartIndex,
                                                 virtualAddress: Swift.UInt64(nextCStringStartIndex) + sectionVirtualAddress,
                                                 length: nextCStringDataLength)

            cStringPosition.explanationItem = translationItem(with: cStringPosition)
            cStringPositions.append(cStringPosition)
            indexOfLastNull = indexOfCurNull
        }

        return cStringPositions
    }

    // 将StringTable index转换为ExplanationItem模型
    func translationItem(with stringPosition: StringPosition) -> ExplanationItem {
        let cStringPosition = stringPosition
        let cStringRelativeRange = cStringPosition.startOffset ..< cStringPosition.startOffset + cStringPosition.length
        let cStringAbsoluteRange = DataTool.absoluteRange(with: self.data, relativeRange: cStringRelativeRange)
        let cStringRaw = DataTool.interception(with: self.data, from: cStringPosition.startOffset, length: cStringPosition.length)

        guard let string = cStringRaw.utf8String else {
            return ExplanationItem(sourceDataRange: cStringAbsoluteRange, model: ExplanationModel(description: "Unable to decode", explanation: "🔥Invalid UTF8 String"))
        }

        let explanation: String = string.replacingOccurrences(of: "\n", with: "\\n")

        return ExplanationItem(sourceDataRange: cStringAbsoluteRange,
                               model: ExplanationModel(description: "UTF8-String", explanation: explanation, extraExplanation: explanation))
    }
}






extension StringInterpreter {
    // 根据距离字符串表首地址 首地址 + 偏移地址 = offset 拿到字符串
    func findString(at offset: Int) -> String? {
        let rawData = self.data
        for index in offset ..< rawData.count {
            let byte = rawData[rawData.startIndex + index]
            if byte != 0 { continue }
            let length = index - offset + 1
            let value = DataTool.interception(with: self.data, from: offset, length: length).utf8String
            return value?.spaceRemoved
        }
        return nil
    }
    
    func findString(with virtualAddress: Swift.UInt64, stringPositionList:[StringPosition]) -> String? {
        for stringPosition in stringPositionList {
            if stringPosition.virtualAddress == virtualAddress {
                return DataTool.interception(with: self.data, from: stringPosition.startOffset, length:  stringPosition.length).utf8String
            }
        }
        return nil
    }
}
