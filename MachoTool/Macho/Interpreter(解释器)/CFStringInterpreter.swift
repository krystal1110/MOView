//
//  CFStringInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/27.
//

import Foundation


 
struct cfstring_t {
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
 

    init(wiht data: DataSlice,
         is64Bit: Bool,
         machoProtocol: MachoProtocol) {
        self.is64Bit = is64Bit
        self.machoProtocol = machoProtocol
        self.data = data
    }
    
 

    // 转换为 stroeInfo 存储信息
    func transitionStoreInfo(title:String , subTitle:String )  {
        /*
        __DATA，__cfstring，存储 Objective C 字符串的元数据，每个元数据占用 32Byte，里面有两个指针：
         内部指针，指向__TEXT，__cstring中字符串的位置；
         外部指针 isa，指向类对象的，这就是为什么可以对 Objective C 的字符串字面量发消息的原因。
        */
        
        
        
        var modelList = MachoModel<CFStringEntryModel>.init().generateVessel(data: self.data, is64Bit: is64Bit)
//        // 在外层转换 因为Model是固定生成的 外层转换后塞进去
        for index in 0..<modelList.count {
//            let item = translationItem(at: index)
        }
//        return LazySymbolStoreInfo(with: self.data, is64Bit:is64Bit, lazySymbolTableList: modelList, title: title, subTitle: subTitle)
    }
    
    
    func translationItem(at index:Int) -> ExplanationItem? {
        return nil
    }
}
