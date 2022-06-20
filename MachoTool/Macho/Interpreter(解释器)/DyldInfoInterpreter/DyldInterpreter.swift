//
//  DyldInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/6.
//

import Foundation


class DyldInterpreter: BaseInterpreter {
    
    init(wiht data: Data,
         is64Bit: Bool,
         machoProtocol: MachoProtocol) {
//        self.pointerLength = is64Bit ? 8 : 4
   
        super.init(data, is64Bit: is64Bit, machoProtocol: machoProtocol, sectionVirtualAddress: 0)
    }
    
    
    
    //  压缩字节流获取元组解析
     func operationCodes()  {
//        var bindInfoDic:Dictionary<String,String> = [:]
        var operationCodes: [OperationCodeModel] = []
        var index: Int = 0
        let rawData = data
        while index < rawData.count {
             
            
            let startIndexOfCurrentOperation = index
            let byte = rawData[rawData.startIndex + index]; index += 1
            
//            这里对应的是两个MAST 高4bit 与 低4bit
//            #define BIND_OPCODE_MASK                    0xF0
//            #define BIND_IMMEDIATE_MASK                    0x0F
            let operationCodeValue = byte & 0xf0 // mask the most significant 4 bits
            let immediateValue = byte & 0x0f // mask the least significant 4 bits
            
            // 获取对应code类型 这里的类型有可能是对后一个数据的解释
            let operationCode = BindOperationCode.init(operationCodeValue: operationCodeValue, immediateValue: immediateValue)
             
       
            
            // 计算数据 拿到每一个对应的元组
            var lebValues: [DyldInfoLEB] = []
            for _ in 0..<operationCode.numberOfTrailingLEB {
                let ulebStartIndex = index
                var delta: Swift.UInt64 = 0 // 用于计算的指针
                var shift: Swift.UInt32 = 0
                var more = true
                
                // 判断是否还有更多数据
                repeat {
                    let lebByte = rawData[rawData.startIndex+index]; index += 1
                    //   (lebByte&0x7f) 左移 shift位 然后与 delta进行 | 操作
                    delta |= ((Swift.UInt64(lebByte) & 0x7f) << shift)
                    shift += 7
                    if lebByte < 0x80 {
                        more = false
                    }
                } while (more)
                
             
                
                let isSigned = operationCode.trailingLEBType == .signed
                
                if (isSigned) {
                
                    let signExtendMask: Swift.UInt64 = ~0
                    
                    delta |= signExtendMask << shift
                }
                
                
                lebValues.append(DyldInfoLEB(absoluteRange:(data.startIndex+ulebStartIndex)..<(data.startIndex + index), raw: delta, isSigned: isSigned))
                
            }
            
            //  如果code为setSymbolTrailingFlagsImm,代表后面是一个字符串，截取
            var cstringData: Data? = nil
            if operationCode.hasTrailingCString {
                let cstringStartIndex = index
                while (rawData[rawData.startIndex+index] != 0) {
                    index += 1
                }
                index += 1 // 最后的\0是字符串的一部分
                cstringData = rawData[rawData.startIndex+cstringStartIndex..<rawData.startIndex+index]
            }
            
            if lebValues.count > 0 {
                print("address == \(lebValues[0].raw)")
            }
            
            if operationCode.bindOperationType == .doBind {
                // 如果是绑定的话
                print(cstringData?.utf8String ?? "unknow symbol")
            }
            
            
           let model = OperationCodeModel.init(absoluteOffset: data.startIndex+startIndexOfCurrentOperation,
                                    operationCode: operationCode,
                                    lebValues: lebValues,
                                               cstringData: cstringData).translationItems
                                    
//            print("---")
//            operationCodes.append(model)
        }
           print("hello")
//        return OperationCodeContainer(operationCodes: operationCodes)
    }
    
 
}



struct DyldInfoLEB {
    let absoluteRange: Range<Int>
    let raw: UInt64
    let isSigned: Bool
}
