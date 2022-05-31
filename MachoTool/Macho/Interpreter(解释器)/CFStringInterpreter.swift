//
//  CFStringInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/27.
//

import Foundation


 
struct ObjcCFString {
    let ptr: UInt64
    let data: UInt64
    let cstr: UInt64
    let size: UInt64
}

/*
    用于解析 （__DATA，_cfstring） -> Objc CFString
 **/
class CFStringInterpreter {
    let data: DataSlice
    let machoProtocol: MachoProtocol
    let is64Bit: Bool
    let pointerLength: Int

    init(wiht data: DataSlice,
         is64Bit: Bool,
         machoProtocol: MachoProtocol) {
        self.is64Bit = is64Bit
        self.pointerLength = is64Bit ? 32 : 4
        self.machoProtocol = machoProtocol
        self.data = data
    }
    
 

        /*
        __DATA，__cfstring，存储 Objective C 字符串的元数据，每个元数据占用 32Byte，里面有两个指针：
         内部指针，指向__TEXT，__cstring中字符串的位置；
         外部指针 isa，指向类对象的，这就是为什么可以对 Objective C 的字符串字面量发消息的原因。
        */
        func transitionStoreInfo(title:String , subTitle:String ) -> CFStringStoreInfo  {
            let rawData = self.data.raw
            guard rawData.count % pointerLength == 0 else { fatalError() /* section of type S_LITERAL_POINTERS should be in align of 8 (bytes) */  }
            var pointers: [ObjcCFString] = []
            let numberOfPointers = rawData.count / 32
            for index in 0..<numberOfPointers {
                let relativeDataOffset = index * pointerLength
                var pointerRawData = rawData.select(from: relativeDataOffset, length: pointerLength)
                
                 
                for index in 0..<4 {
                    let pointer = pointerRawData.select(from: (index * 8) , length: 8)
                    var ptr:UInt64 = 0
                    var data:UInt64 = 0
                    var cstr:UInt64 = 0
                    var size :UInt64 = 0
                    if (index == 0) {
                        ptr = pointer.UInt64
                    }else if (index == 1){
                        data = pointer.UInt64
                    }else if (index == 2){
                        cstr = pointer.UInt64
                       let str =  self.machoProtocol.searchString(by: pointer.UInt64)
                        print(str)
                    }else{
                        size = pointer.UInt64
                    }
                    let objcCFString = ObjcCFString(ptr: ptr, data: data, cstr: cstr, size: size)
                    pointers.append(objcCFString)
                }
            }
            return CFStringStoreInfo(with: self.data, is64Bit:is64Bit,objcCFStringList: pointers,title:title,subTitle: subTitle)
        }
 
}
