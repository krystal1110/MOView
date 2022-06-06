//
//  UStringInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/31.
//
 
import Foundation

struct UStringPosition {
    let relativeStartOffset: Int
    let length: Int
    var explanationItem: ExplanationItem? = nil
}


class UStringInterpreter: BaseInterpreter{
    
    let pointerLength: Int
    init(with dataSlice: Data,
         is64Bit: Bool,
         machoProtocol: MachoProtocol,
         sectionVirtualAddress:UInt64) {
        self.pointerLength = is64Bit ? 8 : 4
        super.init(dataSlice, is64Bit: is64Bit, machoProtocol: machoProtocol, sectionVirtualAddress: sectionVirtualAddress)
    }
    
 
    // 转换为 stroeInfo 存储信息
    func transitionStoreInfo(title:String , subTitle:String ) -> UStringStoreInfo  {
        let rawData = self.data
        let dataLength = rawData.count
        let utf16UnitCount = dataLength / 2
        var uStringPositions: [UStringPosition] = []
        var indexOfLastNull = -2
        for index in 0..<utf16UnitCount {
            let curNullIndex = index * 2
            let utf16UnitValue = rawData.select(from: curNullIndex, length: 2).UInt16
            if utf16UnitValue != 0 { continue }

            let uStringStartIndex = indexOfLastNull + 2
            let uStringDataLength = curNullIndex - uStringStartIndex
            if uStringDataLength == 0 { continue }

            var uStringPosition = UStringPosition(relativeStartOffset: uStringStartIndex,
                                                  length: uStringDataLength)
            uStringPosition.explanationItem = translationItem(with: uStringPosition)
            uStringPositions.append(uStringPosition)
            indexOfLastNull = curNullIndex
        }
        return UStringStoreInfo(with: self.data, interpreter: self, title: subTitle, subTitle: subTitle, sectionVirtualAddress: sectionVirtualAddress, uStringPositionList: uStringPositions)
    }

    
    func translationItem(with uStringPosition: UStringPosition) -> ExplanationItem {
        let uStringRelativeRange = uStringPosition.relativeStartOffset..<uStringPosition.relativeStartOffset+uStringPosition.length
        let uStringAbsoluteRange =  DataTool.absoluteRange(with: self.data, relativeRange: uStringRelativeRange)
        let uStringRaw = DataTool.interception(with: self.data, from: uStringPosition.relativeStartOffset, length: uStringPosition.length)

        if let string = String(data: uStringRaw, encoding: .utf16LittleEndian) {
            return ExplanationItem(sourceDataRange: uStringAbsoluteRange,
                                   model: ExplanationModel(description: "UTF16-String", explanation: string))
        } else {
            return ExplanationItem(sourceDataRange: uStringAbsoluteRange,
                                   model: ExplanationModel(description: "Unable to decode", explanation: "🙅‍♂️ Invalid UTF16 String"))
        }
    }
    
}
