//
//  ClassRefsInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/2.
//
 
import Foundation
  

struct ClassRefsInterpreter: Interpreter {
    
    var dataSlice: Data
    
    var section: Section64?
    
    var searchProtocol: SearchProtocol
    
    let pointerLength: Int = 8
    
    init(with  dataSlice: Data, section:Section64,  searchProtocol:SearchProtocol){
        self.dataSlice = dataSlice
        self.section = section
        self.searchProtocol = searchProtocol
    }
    
 
    // 转换为 stroeInfo 存储信息
    func transitionData() -> [ReferencesPointer]   {
        let rawData = self.dataSlice
        guard rawData.count % pointerLength == 0 else { fatalError() /* section of type S_LITERAL_POINTERS should be in align of 8 (bytes) */  }
        var pointers: [ReferencesPointer] = []
        let numberOfPointers = rawData.count / 8
        for index in 0..<numberOfPointers {
            let relativeDataOffset = index * pointerLength
            let pointerRawData = rawData.select(from: relativeDataOffset, length: pointerLength)
            var pointer = ReferencesPointer(relativeDataOffset: relativeDataOffset,
                                           pointerValue: pointerRawData.UInt64)
            pointer.explanationItem  = translationItem(with: pointer)
            
            pointers.append(pointer)
        }
        return pointers
    }
    
    
    func translationItem(with pointer:ReferencesPointer) -> ExplanationItem {
        
        var searchedString = self.searchProtocol.searchString(by: pointer.pointerValue)
        
        if (searchedString == nil){
            searchedString = self.searchProtocol.searchStringInSymbolTable(by: pointer.pointerValue)
        }
         
        return ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: self.dataSlice, start: pointer.relativeDataOffset, self.pointerLength),
                               model: ExplanationModel(description: "Pointer Value (Virtual Address)",
                                                               explanation: pointer.pointerValue.hex,
                                              
                                                       extraDescription: "Referenced String Symbol",
                                                               extraExplanation: searchedString))
    }
    
}
