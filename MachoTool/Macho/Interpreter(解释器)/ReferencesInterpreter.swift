//
//  ReferencesInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/30.
//

import Foundation
 
struct ReferencesPointer {
    let relativeDataOffset: Int
    let pointerValue: Swift.UInt64
    var explanationItem: ExplanationItem? = nil
}

class ReferencesInterpreter{
    
    let pointerLength: Int
    let data: DataSlice
    let machoProtocol: MachoProtocol
    let is64Bit: Bool
 

    init(wiht data: DataSlice,
         is64Bit: Bool,
         machoProtocol: MachoProtocol) {
        self.pointerLength = is64Bit ? 8 : 4
        self.is64Bit = is64Bit
        self.machoProtocol = machoProtocol
        self.data = data
    }
    
 
    // 转换为 stroeInfo 存储信息
    func transitionStoreInfo(title:String , subTitle:String ) -> ReferencesStoreInfo  {
        let rawData = self.data.raw
        guard rawData.count % pointerLength == 0 else { fatalError() /* section of type S_LITERAL_POINTERS should be in align of 8 (bytes) */  }
        var pointers: [ReferencesPointer] = []
        let numberOfPointers = rawData.count / 8
        for index in 0..<numberOfPointers {
            let relativeDataOffset = index * pointerLength
            let pointerRawData = rawData.select(from: relativeDataOffset, length: pointerLength)
            var pointer = ReferencesPointer(relativeDataOffset: relativeDataOffset,
                                         pointerValue: is64Bit ? pointerRawData.UInt64 : UInt64(pointerRawData.UInt32))
            pointer.explanationItem  = translationItem(with: pointer);
            pointers.append(pointer)
        }
        return ReferencesStoreInfo(with: self.data, is64Bit:is64Bit, referencesPointerList: pointers, title: title, subTitle: subTitle)
    }
    
    
    func translationItem(with pointer:ReferencesPointer) -> ExplanationItem {
        
        var searchedString = self.machoProtocol.searchString(by: pointer.pointerValue)
        
        if (searchedString == nil){
            searchedString = self.machoProtocol.searchStringInSymbolTable(by: pointer.pointerValue)
        }
        
        
        return ExplanationItem(sourceDataRange: self.data.absoluteRange(pointer.relativeDataOffset, self.pointerLength),
                               model: ExplanationModel(description: "Pointer Value (Virtual Address)",
                                                               explanation: pointer.pointerValue.hex,
                                              
                                                       extraDescription: "Referenced String Symbol",
                                                               extraExplanation: searchedString))
    }
    
}
