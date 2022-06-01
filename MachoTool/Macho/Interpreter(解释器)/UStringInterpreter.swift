//
//  UStringInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/31.
//
 
 
struct UStringPosition {
    let relativeStartOffset: Int
    let length: Int
    var explanationItem: ExplanationItem? = nil
}


class UStringInterpreter{
    
    let pointerLength: Int
    let data: DataSlice
    let machoProtocol: MachoProtocol
    let is64Bit: Bool
    let sectionVirtualAddress: UInt64

 

    init(wiht data: DataSlice,
         is64Bit: Bool,
         machoProtocol: MachoProtocol,
         sectionVirtualAddress:UInt64) {
        self.pointerLength = is64Bit ? 8 : 4
        self.is64Bit = is64Bit
        self.machoProtocol = machoProtocol
        self.data = data
        self.sectionVirtualAddress = sectionVirtualAddress
    }
    
 
    // 转换为 stroeInfo 存储信息
    func transitionStoreInfo(title:String , subTitle:String ) -> UStringStoreInfo  {
        let rawData = self.data.raw
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
        return UStringStoreInfo(with: self.data, is64Bit: is64Bit, interpreter: self, uStringPositionList: uStringPositions, title: subTitle, subTitle: subTitle)
    }
    
    
    func translationItem(with uStringPosition: UStringPosition) -> ExplanationItem {
        let uStringRelativeRange = uStringPosition.relativeStartOffset..<uStringPosition.relativeStartOffset+uStringPosition.length
        let uStringAbsoluteRange = self.data.absoluteRange(uStringRelativeRange)
        let uStringRaw = self.data.interception(from: uStringPosition.relativeStartOffset, length: uStringPosition.length).raw
        
        if let string = String(data: uStringRaw, encoding: .utf16LittleEndian) {
            return ExplanationItem(sourceDataRange: uStringAbsoluteRange,
                                   model: ExplanationModel(description: "UTF16-String", explanation: string))
        } else {
            return ExplanationItem(sourceDataRange: uStringAbsoluteRange,
                                   model: ExplanationModel(description: "Unable to decode", explanation: "🙅‍♂️ Invalid UTF16 String"))
        }
    }
    
}
