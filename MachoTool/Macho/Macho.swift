//
//  Macho.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/8.
//

import Foundation

fileprivate struct MachAttributes {
    let is64Bit: Bool
    let isByteSwapped: Bool
}

class Macho: Equatable {
    static func == (lhs: Macho, rhs: Macho) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    var is64bit = false
    let id = UUID()
    let data:Data
    var fileSize: Int { data.count }
    let machoFileName: String
    
    let header: MachOHeader
    
    var parseSymbolTool: ParseSymbolTool
    
    var allBaseStoreInfoList: [BaseStoreInfo] = []
    
    
    // loadCommands
    let commands: [MachOLoadCommandType]
    
    var componts: [ComponentInfo] = []
    
     
    
    
    init(machoDataRaw: Data, machoFileName: String) {
        data = machoDataRaw
        self.machoFileName = machoFileName
       
        //        var loadCommands: [MachoComponent] = []
        
        guard let magicType = MagicType(data) else { fatalError() }
        
        let is64bit = magicType == .macho64
        self.is64bit = is64bit
        
        // read headerparseTextSection.componts
        header = Macho.readMachOHeader(dataSlice: data)
        
        
        self.commands = Macho.loadCommands(from: data, header: header, attributes: Macho.machAttributes(from: data))
        
        // parse LC_SYMTAB    // parse LC_DYSYMTAB
        self.parseSymbolTool = ParseSymbolTool()
        self.parseSymbolTool.parseSymbol(data, commonds: self.commands, searchProtocol: self)
        
        
        // parse LC_DYSYMTAB
        
        // parse __TEXT
        let parseTextSection = ParseTextSection()
        parseTextSection.parseTextSection(data, commonds: self.commands, searchProtocol: self)
        self.componts.append(contentsOf: parseTextSection.componts)
        
        // parse __DATA
        let parseDataSection = ParseDataSection()
        parseDataSection.parseDataSection(data, commonds: self.commands, searchProtocol: self)
        self.componts.append(contentsOf: parseDataSection.componts)
        
        // parse custome section64
        let parseCustomSection = ParseCustomSection()
        parseCustomSection.parseCustomSections(data, commonds: self.commands, searchProtocol: self)
        self.componts.append(contentsOf: parseCustomSection.componts)
        
  
 
        
        
//      UnusedScanManager.init(with: componts,parseSymbolTool: parseSymbolTool)
        
    }

    
   
    #warning("TODO  待迁移 dyldInfo段")
    //    func dyldInfoComponts(wiht command:DyldInfoCommand){
    //
    //        /*
    //         处理rebase数据
    //         **/
    //        let rebaseInfoStart = Int(command.rebaseOffset)
    //        let rebaseInfoSize = Int(command.rebaseSize)
    //        if rebaseInfoStart.isNotZero && rebaseInfoSize.isNotZero { // 非空判断
    //            let rebaseInfoData = DataTool.interception(with: data, from: rebaseInfoStart, length: rebaseInfoSize)
    //            DyldInterpreter.init(wiht: <#T##Data#>, is64Bit: <#T##Bool#>, SearchProtocol: <#T##SearchProtocol#>, sectionVirtualAddress: <#T##UInt64#>)
    //        }
    //
    //
    //
    //        /*
    //         处理bind数据
    //         **/
    //        let bindInfoStart = Int(command.bindOffset)
    //        let bindInfoSize = Int(command.bindSize)
    //        if bindInfoStart.isNotZero && bindInfoSize.isNotZero { // 非空判断
    //            let bindInfoData = DataTool.interception(with: data, from: bindInfoStart, length: bindInfoSize)
    //            let interpreter = DyldInterpreter.init(wiht: bindInfoData, is64Bit: is64bit, SearchProtocol: self).operationCodes()
    //        }
    //
    //
    //    }
    
    
    

    

    
}

extension Macho: SearchProtocol {
    
    
    
    func sectionName(at ordinal: Int) -> String {
        if ordinal > self.componts.count {
            fatalError()
        }
        // ordinal starts from 1
        let sectionHeader = self.componts[ordinal - 1]
        return sectionHeader.componentTitle ?? "unknown" + "," + (sectionHeader.componentSubTitle ?? "unknown")
    }
    
    
    func searchInIndirectSymbolTableList(at index: Int) -> String? {

        return self.parseSymbolTool.findStringInIndirectSymbolList(at: index)
    }
    
    
    // 查找字符串根据 SymbolTableList数组中的索引index查找符号
    func searchStringInSymbolTableIndex(at index: Int)  -> String? {
         return  self.parseSymbolTool.findStringWithIndex(at: index)
    }
    
    // 查找字符串  offset 为 indexInStringTable
    func stringInStringTable(at offset: Int) -> String? {
        return self.parseSymbolTool.findStringWithIndex(at: offset)
    }
    
    
    // 根据symbolTable 的nvalue 查找 string
    func searchStringInSymbolTable(by nValue:UInt64) -> String?{
       return self.parseSymbolTool.findStringInSymbolTable(by: nValue)
    }
    
    
    
#warning("TODO  待修复 寻找Cstring")
    func searchString(by virtualAddress: UInt64) -> String? {
        
//        if (self.uStringStoreInfo != nil){
//            for item in self.uStringStoreInfo!.uStringPositionList {
//                let itemVirtualAddress =  Int(self.uStringStoreInfo!.interpreter.sectionVirtualAddress) + item.relativeStartOffset
//                if (itemVirtualAddress == virtualAddress){
//                    return item.explanationItem?.model.explanation
//                }
//            }
//        }
//        for stringTableStoreInfo in self.allCstringInterpretInfo {
//            // 判断区间范围
//            if virtualAddress >= stringTableStoreInfo.interpreter.sectionVirtualAddress
//                && virtualAddress < (stringTableStoreInfo.interpreter.sectionVirtualAddress + UInt64(stringTableStoreInfo.interpreter.data.count)) {
//                return stringTableStoreInfo.interpreter.findString(with: virtualAddress, stringPositionList: stringTableStoreInfo.stringTableList)
//            }
//        }
        return nil
    }
}




/*
 MachO - Header读取
 **/
extension Macho {
    static func readMachOHeader(dataSlice:Data) -> MachOHeader {
        let attributes = Macho.machAttributes(from: dataSlice)
        let header = Macho.header(from: dataSlice, attributes: attributes)
        return header
    }
    
    private static func machAttributes(from data: Data) -> MachAttributes {
        let magic = data.readU32(offset: 0)
        let is64Bit = magic == MH_MAGIC_64 || magic == MH_CIGAM_64
        let isByteSwapped = magic == MH_CIGAM || magic == MH_CIGAM_64
        return MachAttributes(is64Bit: is64Bit, isByteSwapped: isByteSwapped)
    }
    
    private static func header(from data: Data, attributes: MachAttributes) -> MachOHeader {
        if attributes.is64Bit {
            let header =  data.extract(mach_header_64.self)
            return MachOHeader(header: header)
        } else {
            let header = data.extract(mach_header.self)
            return MachOHeader(header: header)
        }
    }
}



/*
 MachO - LC_SEGMENT 与 LC_SEGMENT_64 读取
 __PAGEZERO / __TEXT / __DATA / __LINKEDIT / 自定义段 / ......
 **/
extension Macho {
    private static func loadCommands(from data: Data, header: MachOHeader, attributes: MachAttributes) -> [MachOLoadCommandType] {
        var segmentCommands: [MachOLoadCommandType] = []
        var offset = header.size
        for _ in 0..<header.loadCommandCount {
            let loadCommand = MachOLoadCommand(data: data, offset: offset, byteSwapped: attributes.isByteSwapped)
            if let command = loadCommand.command(from: data, offset: offset, byteSwapped: attributes.isByteSwapped) {
                segmentCommands.append(command)
            }
            offset += Int(loadCommand.size)
        }
        return segmentCommands
    }
}


 
