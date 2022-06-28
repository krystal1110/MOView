//
//  ParseSYMTAB.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/27.
//

import Foundation
import MachO



/*
 用于解析 String Table / Symbol Table / Indirect Symbol Table
 **/
class ParseSymbolTool{
    
    
    var componts: [ComponentInfo] = []
    
    var stringInterpreter: StringInterpreter?
    
    var symbolTableComponent:SymbolTableComponent?
    
    var indsymComponent:IndsymComponent?
    
    func parseSymbol(_ data:Data ,commonds: [MachOLoadCommandType], searchProtocol: SearchProtocol){
        
        for item in commonds {
            
            if item.name  == LoadCommandType.symbolTable.name {
                // parse 字符串表 以及 符号表
                let command =  item as! MachOLoadCommand.LC_SymbolTable
                parseSymbolTable(data, command: command.command!, searchProtocol: searchProtocol)
                parseStringTable(data, command: command.command!, searchProtocol: searchProtocol)
                 
            }else if item.name == LoadCommandType.dynamicSymbolTable.name{
               // parse 间接符号表
                let command =  item as! MachOLoadCommand.LC_DynamicSymbolTable
                parseIndsymTable(data, command:  command.command!, searchProtocol: searchProtocol)
                
            }
        }
        print("🔥🔥🔥 解析 Symbol 完成  🔥🔥🔥")
         
    }
    
    
    
    
    
    
    // Parse SymbolTable
    func parseSymbolTable(_ data: Data , command: symtab_command , searchProtocol: SearchProtocol) {
        let symbolTableStartOffset = Int(command.symoff)
        let numberOfEntries = Int(command.nsyms)
        let entrySize = 16
        let modelSize :Int = 16
        
        let symbolTableData = DataTool.interception(with: data, from: symbolTableStartOffset, length: numberOfEntries * entrySize)
        
        let numberOfModels = symbolTableData.count / modelSize
        var models: [SymbolTableModel] = []
        for index in 0 ..< numberOfModels {
            let startIndex = index * modelSize
            let modelData = DataTool.interception(with: symbolTableData, from: startIndex, length: modelSize)
            let model = SymbolTableModel(with: modelData, searchProtocol: searchProtocol)
            models.append(model)
        }
        
        let compont = SymbolTableComponent(symbolTableData, symbolTableList: models)
        self.symbolTableComponent = compont
        componts.append(compont)
    }
    
    
    func parseStringTable(_ data: Data , command: symtab_command , searchProtocol: SearchProtocol){
        
        let stringTableStartOffset = Int(command.stroff)
        
        let stringTableSize = Int(command.strsize)
        
        let stringTableData = DataTool.interception(with: data, from: stringTableStartOffset, length: stringTableSize)
        
        let interpreter = StringInterpreter(with: stringTableData, section: nil, searchProtocol: searchProtocol)
        
        self.stringInterpreter = interpreter
        
        let stringTableList = interpreter.transitionData()
        
        let compont = StringComponent(data, section: nil, stringList: stringTableList)
        
        componts.append(compont)
    }
    
    
    func parseIndsymTable(_ data: Data , command: dysymtab_command , searchProtocol: SearchProtocol){
        
 
        
        let indirectSymbolTableStartOffset = Int(command.indirectsymoff)
        let indirectSymbolTableSize = Int(command.nindirectsyms * 4)
        if indirectSymbolTableSize == .zero {
            return
        }
        let indirectSymbolTableData = DataTool.interception(with: data, from: indirectSymbolTableStartOffset, length: indirectSymbolTableSize)
        
        let interpreter = IndirectSymbolTableInterpreter(with: indirectSymbolTableData, section: nil, searchProtocol: searchProtocol)
        
         
        
        let indirectTableList = interpreter.transitionData()
        
        let compont = IndsymComponent(data, indirectSymbolTableList: indirectTableList)
        self.indsymComponent = compont
        componts.append(compont)
    }
    
    
    
    
    
    
    
    // 根据 符号表 nValue 查找 字符串
    func findStringInSymbolTable(by nValue:UInt64) -> String? {
        
        guard let symbolTableList = self.symbolTableComponent?.symbolTableList else{return nil}
        
        for model in symbolTableList {
            if (nValue == model.nValue){
                return self.findStringWithIndex(at: Int(model.indexInStringTable))
            }
        }
        return nil
    }
    
    
    // 根据 符号表 indexInStringTable 查找 字符串
    func findStringWithIndex(at index:Int) -> String? {
        guard let stringInterpreter = self.stringInterpreter else{return nil}
        return stringInterpreter.findString(at: index)
    }
    
    
    // 根据 符号表SymbolTableList 索引（symbolTableIndex） 字符串
    func findStringInSymbolTableList(at index:Int) -> String? {
        guard let symbolTableList = self.symbolTableComponent?.symbolTableList else{return nil}
        if index > symbolTableList.count {return nil} 
        return  symbolTableList[index].findSymbolName()
    }
    
    // 根据 间接符号表 索引 来找到字符串
    func findStringInIndirectSymbolList(at index:Int) -> String? {
         
        guard let indsymList = self.indsymComponent?.indirectSymbolTableList else{return nil}
        return findStringInSymbolTableList(at: indsymList[index].symbolTableIndex)
    }
 
    
}
//func indexInIndirectSymbolTable(at index: Int) -> IndirectSymbolTableEntryModel? {
////        if let indirectInterpreInfo = indirectSymbolTableStoreInfo {
////            let indirectEntryModel = indirectInterpreInfo.indirectSymbolTableList[index]
////            return indirectEntryModel
////        }
//    return nil
//}
