//
//  StubsInterpreter.swift
//  MachOTool
//
//  Created by karthrine on 2022/8/15.
//

import Foundation

struct StubsPointer {
    let offset: Int
    let value: String
    var explanationItem: ExplanationItem? = nil
}

//StubsInterpreter

struct StubsInterpreter: Interpreter {
    
    var dataSlice: Data
    
    var section: Section64?
    
    var searchProtocol: SearchProtocol
    
    let pointerLength: Int = 12
    
    init(with  dataSlice: Data, section:Section64,  searchProtocol:SearchProtocol){
        self.dataSlice = dataSlice
        self.section = section
        self.searchProtocol = searchProtocol
    }
    
    
    
    
    
    func transitionData() -> [StubsPointer]  {
         
        let rawData = self.dataSlice
        guard rawData.count % pointerLength == 0 else { fatalError() /* section of type S_LITERAL_POINTERS should be in align of 8 (bytes) */  }
        var pointers: [StubsPointer] = []
        let numberOfPointers = rawData.count / pointerLength
        
        
        for index in 0..<numberOfPointers {
            
            let relativeDataOffset = index * pointerLength
            let pointerRawData = DataTool.interception(with: searchProtocol.getMachoData(), from: rawData.startIndex + relativeDataOffset, length: pointerLength)
            let rva64 = fileOffsetToRVA64(UInt32(pointerRawData.startIndex))
            let symbolName = self.searchProtocol.findSymbol(at: rva64)
            var pointer = StubsPointer(offset: pointerRawData.startIndex, value: symbolName)
            let pointerRange = DataTool.absoluteRange(with: searchProtocol.getMachoData(), start: pointerRawData.startIndex, self.pointerLength);
            
            
            
            pointer.explanationItem =    ExplanationItem(sourceDataRange: pointerRange, model: ExplanationModel(description: "offset",
                                                                                   explanation: pointerRawData.startIndex.hex,
                                                                                extraDescription:"Symbol Name",
                                                                                  extraExplanation: symbolName))
 
            
            pointers.append(pointer)
                                                      
            
            
        }
        return pointers
    }
    
    
 
    
    func fileOffsetToRVA64(_ offset:UInt32) -> UInt64{
        guard let section = section else {
            return 0
        }
        return  UInt64(UInt64(offset) + (section.info.addr - UInt64(section.fileOffset)))
    }
}


 
