//
//  ClassRefsInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/2.
//
 
import Foundation
 
struct ClassRefsPointer {
    let relativeDataOffset: Int
    let pointerValue: Swift.UInt64
    var explanationItem: ExplanationItem? = nil
}

class ClassRefsInterpreter: BaseInterpreter{
    
    let pointerLength: Int

    init(wiht data: Data,
         is64Bit: Bool,
         machoProtocol: MachoProtocol,
         sectionVirtualAddress: UInt64) {
        self.pointerLength = is64Bit ? 8 : 4
   
        super.init(data, is64Bit: is64Bit, machoProtocol: machoProtocol, sectionVirtualAddress: sectionVirtualAddress)
    }
    
 
    // 转换为 stroeInfo 存储信息
    func transitionStoreInfo(title:String , subTitle:String )   {
        let rawData = self.data
        guard rawData.count % pointerLength == 0 else { fatalError() /* section of type S_LITERAL_POINTERS should be in align of 8 (bytes) */  }
        var pointers: [ClassRefsPointer] = []
        let numberOfPointers = rawData.count / 8
        for index in 0..<numberOfPointers {
            let relativeDataOffset = index * pointerLength
            let virtualAddress = Int(self.sectionVirtualAddress)  + relativeDataOffset
//            virtualAddress.hex
            let pointerRawData = rawData.select(from: relativeDataOffset, length: pointerLength)
            var pointer = ClassRefsPointer(relativeDataOffset: relativeDataOffset,
                                           pointerValue: is64Bit ? pointerRawData.UInt64 : UInt64(pointerRawData.UInt32))
            pointer.explanationItem  = translationItem(with: pointer)
            
//            pointers.append(pointer)
        }
//        return ReferencesStoreInfo(with: self.data, is64Bit:is64Bit, referencesPointerList: pointers, title: title, subTitle: subTitle)
    }
    
    
    func translationItem(with pointer:ClassRefsPointer) -> ExplanationItem {
        
        var searchedString = self.machoProtocol.searchString(by: pointer.pointerValue)
        
        if (searchedString == nil){
            searchedString = self.machoProtocol.searchStringInSymbolTable(by: pointer.pointerValue)
        }
         
        return ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: self.data, start: pointer.relativeDataOffset, self.pointerLength),
                               model: ExplanationModel(description: "Pointer Value (Virtual Address)",
                                                               explanation: pointer.pointerValue.hex,
                                              
                                                       extraDescription: "Referenced String Symbol",
                                                               extraExplanation: searchedString))
    }
    
}
