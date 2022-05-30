//
//  ObjcPointer64Interpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/28.
//

import Foundation


 

class ObjcPointer64Interpreter {
    let data: DataSlice
    let machoProtocol: MachoProtocol
    let is64Bit: Bool
 

    init(wiht data: DataSlice,
         is64Bit: Bool,
         machoProtocol: MachoProtocol) {
        self.is64Bit = is64Bit
        self.machoProtocol = machoProtocol
        self.data = data
    }
    
    
    
    // 转换为 stroeInfo 存储信息
    func transitionStoreInfo(title:String , subTitle:String )  {
        
        
        self.data.startOffset
        var modelList = MachoModel<ObjcPointer64EnterModel>.init().generateVessel(data: self.data, is64Bit: is64Bit)
//        // 在外层转换 因为Model是固定生成的 外层转换后塞进去
        for index in 0..<modelList.count {
            var model = modelList[index]
//            let item = translationItem(at: index)
        }
//        return LazySymbolStoreInfo(with: self.data, is64Bit:is64Bit, lazySymbolTableList: modelList, title: title, subTitle: subTitle)
    }
    
    func translationItem(at index:Int) -> ExplanationItem? {
        var ptr =  self.data.interception(from:0 , length: 8).raw
//        return nil
        
        
        //调用
        //构造包结构体
//        var packetStruct =  Prototype(param1: 1,param2: 2,param3: 3,param4: 4)
        //生成协议包
//        var data = getPacket(pointer: &packetStruct, data: nil, size:   MemoryLayout.size(ofValue: packetStruct))
        
        
        //使用
//        let structs = getStruct(pointer: &data!)
//           print("param1:\(structs.param1)\nparam2:\(structs.param2)\nparam3:\(structs.param3)\nparam4:\(structs.param4)")
        return nil
    }
    
    //从data转换结构体指针
      func getStruct(pointer:UnsafePointer<Data>)->UnsafePointer<Prototype>.Pointee{
       
            unsafeBitCast(pointer, to: UnsafePointer<Prototype>.self).pointee
        }
    
    func getPacket(pointer:UnsafeRawPointer,data:Data!,size:Int) -> Data? {
           //根据结构体构造Data数据
           var ahpack:Data = Data(bytes: pointer, count:size)
           //添加附加数据
            if data != nil{
                ahpack.append(data!)
            }
           return ahpack
        }
        //自定义协议包头
        struct Prototype {
         let   param1:UInt16
         let   param2:UInt16
         let   param3:UInt16
         let   param4:UInt16
        }
}
