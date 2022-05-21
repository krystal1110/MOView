//
//  BaseInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/18.
//

import Foundation

 

protocol SeachStringTable: AnyObject {
    
    // cpu信息
    var cpuType: CPUType{get}
    var cpuSubType: CPUSubtype{get}
    
    
    //搜索str
    func searchStrInStringTable(at offset: Int) ->String?
    func searchString(wiht virtualAddress: UInt64) -> String?
    
    //搜索符号表
    func symbolInSymbolTable(with virtualAddress: UInt64) -> JYSymbolTableEntryModel?
    func symbolInSymbolTable(at index:Int) -> JYSymbolTableEntryModel?
    
    //在间接符号表中搜索
    func searchIndirectSymbolTable(at index:Int)
    
}

//extension JYMacho: SeachStringTable{
//    var cpuType: CPUType {
//        header.cpuType
//    }
//
//    var cpuSubType: CPUSubtype {
//        header.cpuSubtype
//    }
//
//    func searchStrInStringTable(at offset: Int) -> String? {
//        return nil
//    }
//
//    func searchString(wiht virtualAddress: UInt64) -> String? {
//        return nil
//    }
//
//    func symbolInSymbolTable(with virtualAddress: UInt64) -> JYSymbolTableEntryModel? {
////        if let symbolTableInterpreter = self.
//    }
//
//    func symbolInSymbolTable(at index: Int) -> JYSymbolTableEntryModel? {
//
//    }
//
//    func searchIndirectSymbolTable(at index: Int) {
//
//    }
//}

