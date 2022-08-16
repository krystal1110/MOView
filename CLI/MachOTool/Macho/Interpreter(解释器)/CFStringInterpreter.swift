//
//  CFStringInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/27.
//

import Foundation

struct CFString64
{
    let ptr: UInt64
    let unknown: UInt64
    let stringAddress: UInt64
    let size: UInt64
}

struct ObjcCFString {
    let cfString64:CFString64
    let stringName:String
    var explanationItems: [ExplanationItem] = []
}

/*
 用于解析 （__DATA，_cfstring） -> Objc CFString
 **/

struct CFStringInterpreter: Interpreter {
    
    var dataSlice: Data
    
    var section: Section64?
    
    var searchProtocol: SearchProtocol
    
    let pointerLength: Int = 32
    
    init(with  dataSlice: Data, section:Section64,  searchProtocol:SearchProtocol){
        self.dataSlice = dataSlice
        self.section = section
        self.searchProtocol = searchProtocol
    }
    
    /*
     __DATA，__cfstring，存储 Objective C 字符串的元数据，每个元数据占用 32Byte，里面有两个指针：
     内部指针，指向__TEXT，__cstring中字符串的位置；
     外部指针 isa，指向类对象的，这就是为什么可以对 Objective C 的字符串字面量发消息的原因。
     */
    func transitionData() -> [ObjcCFString]  {
        let rawData = self.dataSlice
        guard rawData.count % pointerLength == 0 else { fatalError() /* section of type S_LITERAL_POINTERS should be in align of 8 (bytes) */  }
        var pointers: [ObjcCFString] = []
        let numberOfPointers = rawData.count / 32
        for index in 0..<numberOfPointers {
           
            let relativeDataOffset = index * pointerLength
            let pointerRawData = rawData.select(from: relativeDataOffset, length: pointerLength)
            
            let ptr = pointerRawData.select(from: 0 , length: 8).UInt64
            let unknown = pointerRawData.select(from: 8 , length: 8).UInt64
            let stringAddress = pointerRawData.select(from: 16 , length: 8).UInt64
            let size = pointerRawData.select(from: 24 , length: 8).UInt64
           
            let cfstring =  CFString64(ptr: ptr, unknown: unknown, stringAddress: stringAddress, size: size)
            let stringOff = searchProtocol.getOffsetFromVmAddress(cfstring.stringAddress)
          
            var explanationItems: [ExplanationItem] = []
            if (stringOff > 0 && stringOff < searchProtocol.getMachoData().count) {
                
                let ptrRange = DataTool.absoluteRange(with: pointerRawData, start: 0, 8)
                explanationItems.append(ExplanationItem(sourceDataRange: ptrRange, model: ExplanationModel(description: "CFString Ptr", explanation: "\(ptr)")))
                
                let unknownRange =  DataTool.absoluteRange(with: pointerRawData, start: 8, 8)
                explanationItems.append(ExplanationItem(sourceDataRange: unknownRange, model: ExplanationModel(description: "Unknown Title", explanation: unknown.hex)))
                
                
                let string = searchProtocol.getMachoData().readCStringName(from: Int(stringOff))
                
                let stringRange = DataTool.absoluteRange(with: pointerRawData, start: 16, 8)
                explanationItems.append(ExplanationItem(sourceDataRange: stringRange, model: ExplanationModel(description: "String", explanation: string ?? "")))
                
                
                let sizeRange = DataTool.absoluteRange(with: pointerRawData, start: 24, 8)
                explanationItems.append(ExplanationItem(sourceDataRange: sizeRange, model: ExplanationModel(description: "Size", explanation: "\(size)")))
                
                let objcCFString = ObjcCFString(cfString64: cfstring, stringName: "string",explanationItems: explanationItems)
                    
                pointers.append(objcCFString)
            }
            
        }
        return pointers
    }
    
  
    
}
