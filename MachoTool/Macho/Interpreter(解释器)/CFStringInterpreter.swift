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
//    let ptr: UInt64
//    let data: UInt64
//    let cstrPointer: UInt64
//    let cstrValue: String?
//    let size: UInt64
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
        
        var count = 0
        
        for index in 0..<numberOfPointers {
           
            let relativeDataOffset = index * pointerLength
            let pointerRawData = rawData.select(from: relativeDataOffset, length: pointerLength)
            
            let ptr = pointerRawData.select(from: 0 , length: 8).UInt64
            let unknown = pointerRawData.select(from: 8 , length: 8).UInt64
            let stringAddress = pointerRawData.select(from: 16 , length: 8).UInt64
            let size = pointerRawData.select(from: 24 , length: 8).UInt64
           
            let cfstring =  CFString64(ptr: ptr, unknown: unknown, stringAddress: stringAddress, size: size)
            let stringOff = searchProtocol.getOffsetFromVmAddress(cfstring.stringAddress)
            if (stringOff > 0 && stringOff < searchProtocol.getMachoData().count) {
                
                if let string =  searchProtocol.getMachoData().readClassString(from: Int(stringOff)){
                    count = count + 1
                    let objcCFString = ObjcCFString(cfString64: cfstring, stringName: string)
                    pointers.append(objcCFString)
                }else{
                    print("index  ====  \(index)")
                   
                }
            }
            
        }
        return pointers
    }
    
}
