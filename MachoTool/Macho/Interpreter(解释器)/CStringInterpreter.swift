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
}


class CStringInterpreter{
//    var cpuType: CPUType
    
//    var cpuSubType: CPUSubtype
    
    let data: JYDataSlice
    
    let is64bit: Bool
    
    weak var searchSource: SeachStringTable!
    
//    let sectionVirtualAddress: UInt64
    
    init(_ data: JYDataSlice, is64Bit: Bool ,searchSouce:SeachStringTable ) {
        self.data = data
        self.is64bit = is64Bit
        self.searchSource = searchSouce
        
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
    
    func findString(at offset: Int) -> String? {
        let rawData = self.data.raw
        for index in offset..<rawData.count {
            let byte = rawData[rawData.startIndex+index]
            if byte != 0 { continue }
            let length = index - offset + 1
            return self.data.interception(from: offset, length: length).raw.utf8String
        }
        return nil
    }
    
//    func findString(with virtualAddress: Swift.UInt64) -> String? {
//        for cStringPosition in self.payload {
//            if cStringPosition.virtualAddress == virtualAddress {
//                return self.data.truncated(from: cStringPosition.startOffset, length: cStringPosition.length).raw.utf8String
//            }
//        }
//        return nil
//    }
}
