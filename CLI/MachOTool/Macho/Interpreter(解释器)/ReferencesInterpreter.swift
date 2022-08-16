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


struct ReferencesInterpreter: Interpreter {
    
    var dataSlice: Data
    
    var section: Section64?
    
    var searchProtocol: SearchProtocol
    
    let pointerLength: Int = 8
    
    init(with  dataSlice: Data, section:Section64,  searchProtocol:SearchProtocol){
        self.dataSlice = dataSlice
        self.section = section
        self.searchProtocol = searchProtocol
    }
    
    
    
    
    
    func transitionData() -> [ReferencesPointer]  {
         
        let rawData = self.dataSlice
        guard rawData.count % pointerLength == 0 else { fatalError() /* section of type S_LITERAL_POINTERS should be in align of 8 (bytes) */  }
        var pointers: [ReferencesPointer] = []
        let numberOfPointers = rawData.count / 8
        
        
        for index in 0..<numberOfPointers {
            
            let relativeDataOffset = index * pointerLength
                let pointerRawData = rawData.select(from: relativeDataOffset, length: pointerLength)
             
                var pointer = ReferencesPointer(relativeDataOffset: relativeDataOffset,
                                             pointerValue:pointerRawData.UInt64)
                pointer.explanationItem  = ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: dataSlice,
                                                                                                   start:pointer.relativeDataOffset, self.pointerLength),
                                                          model: ExplanationModel(description: "Offset",
                                                                                  explanation: "\(pointerRawData.startIndex.hex)",
                                                                                  
                                                                                  extraDescription: "Pointer Value (Virtual Address)",
                                                                                  extraExplanation: pointer.pointerValue.hex))
            
                pointers.append(pointer)
            
        }
        return pointers
    }
    
 
    
}


 
