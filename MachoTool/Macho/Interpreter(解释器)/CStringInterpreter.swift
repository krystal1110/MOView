//
//  CStringInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/18.
//

import Foundation

struct CStringPosition {
    let startOffset: Int
    let virtualAddress: Swift.UInt64
    let length: Int
    let value:String?
}


class CStringInterpreter{
    
    let data: DataSlice
    
    let is64bit: Bool
    
    weak var searchSource: SeachStringTable?
    let sectionVirtualAddress: UInt64
    
    init(with data: DataSlice, is64Bit: Bool ,sectionVirtualAddress: UInt64,searchSouce:SeachStringTable? = nil ) {
        self.data = data
        self.is64bit = is64Bit
        self.sectionVirtualAddress = sectionVirtualAddress
        self.searchSource = searchSouce
        
    }
    
     func generatePayload() -> [CStringPosition] {
        let rawData = self.data.raw
        var cStringPositions: [CStringPosition] = []
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
            let value =  self.findString(at: nextCStringStartIndex);
            let cStringPosition = CStringPosition(startOffset: nextCStringStartIndex,
                                                  virtualAddress: Swift.UInt64(nextCStringStartIndex) + sectionVirtualAddress,
                                                  length: nextCStringDataLength,
                                                  value: value)
            cStringPositions.append(cStringPosition)
            indexOfLastNull = indexOfCurNull
        }
        
        return cStringPositions
    }
    
    
//    func searchStrInStringTable(at offset: Int) -> String? {
//
//    }
//
//    func searchString(wiht virtualAddress: UInt64) -> String? {
//
//    }
//
//    func symbolInSymbolTable(with virtualAddress: UInt64) -> JYSymbolTableEntryModel? {
//
//    }
//
//    func symbolInSymbolTable(at index: Int) -> JYSymbolTableEntryModel? {
//
//    }
//
//    func searchIndirectSymbolTable(at index: Int) {
//
//    }
    
    
    func translationItem(with stringPosition: CStringPosition) -> ExplanationItem {
        let cStringPosition = stringPosition
        let cStringRelativeRange = cStringPosition.startOffset..<cStringPosition.startOffset+cStringPosition.length
        let cStringAbsoluteRange = self.data.absoluteRange(cStringRelativeRange)
        let cStringRaw = self.data.interception(from: cStringPosition.startOffset, length: cStringPosition.length).raw
        
        guard let string = cStringRaw.utf8String else{
            return ExplanationItem(sourceDataRange: cStringAbsoluteRange, model: ExplanationModel(description: "Unable to decode", explanation: "🔥Invalid UTF8 String"))
        }
        
        let explanation: String = string.replacingOccurrences(of: "\n", with: "\\n")
      
        return ExplanationItem(sourceDataRange: cStringAbsoluteRange,
                               model: ExplanationModel(description: "UTF8-String", explanation: explanation, extraExplanation: explanation))
        
        
    }
    
    
}



extension CStringInterpreter {
    
    // 根据距离字符串表首地址 首地址 + 偏移地址 = offset 拿到字符串
    func findString(at offset: Int) -> String? {
        let rawData = self.data.raw
        for index in offset..<rawData.count {
            let byte = rawData[rawData.startIndex+index]
            if byte != 0 { continue }
            let length = index - offset + 1
            let value = self.data.interception(from: offset, length: length).raw.utf8String
            return  value?.spaceRemoved
        }
        return nil
    }
    
 
}
 
