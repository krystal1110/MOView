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
    
    
    
    let id = UUID()
    let data:Data
    var fileSize: Int { data.count }
    let machoFileName: String
    
     let header: MachOHeader
    
    var parseSymbolTool: ParseSymbolTool
    
    var allBaseStoreInfoList: [BaseStoreInfo] = []
    
    // loadCommands
    let commands: [MachOLoadCommandType]
    
    // all display modules
    var modules: [MachoModule] = []
    
    
    init(machoDataRaw: Data, machoFileName: String)  {
        data = machoDataRaw
        self.machoFileName = machoFileName
 
        // read headerparseTextSection.componts
        header = Macho.readMachOHeader(dataSlice: data)
        modules.append(HeaderModule(with: data, header:header))
        
        
        // parse load command
        self.commands = Macho.loadCommands(from: data, header: header, attributes: Macho.machAttributes(from: data))
        
        for command in self.commands {
          let module = LoadCommandModule(with: command.displayStore)
          modules.append(module)
        }

        
        // parse LC_SYMTAB    // parse LC_DYSYMTAB
        self.parseSymbolTool = ParseSymbolTool()
        self.parseSymbolTool.parseSymbol(data, commonds: self.commands, searchProtocol: self)
        self.modules.append(contentsOf: self.parseSymbolTool.modules)

        // parse __TEXT
        let parseTextSection = ParseTextSection()
        parseTextSection.parseTextSection(data, commonds: self.commands, searchProtocol: self)
        self.modules.append(contentsOf: parseTextSection.modules)

        // parse __DATA
        let parseDataSection = ParseDataSection()
        parseDataSection.parseDataSection(data, commonds: self.commands, searchProtocol: self)
        self.modules.append(contentsOf: parseDataSection.modules)

        // parse custome section64
        let parseCustomSection = ParseCustomSection()
        parseCustomSection.parseCustomSections(data, commonds: self.commands, searchProtocol: self)
        self.modules.append(contentsOf: parseCustomSection.modules)


        let parseDyldInfo = ParseDyldInfo()
        parseDyldInfo.parseDyldInfo(data, commonds: self.commands, searchProtocol: self)
    }
}

extension Macho: SearchProtocol {
    func getMax() -> Int {
        return self.data.count
    }
    
    func getTEXTConst(_ address: UInt64) -> section_64? {
        for i in self.commands {
            let type  = type(of: i)
            
            if (type == MachOLoadCommand.Segment.self){
                let segment = i as! MachOLoadCommand.Segment
                if  let segmentCommand =  (i as! MachOLoadCommand.Segment).command64 {
                    if (address >= segmentCommand.vmaddr && address <= segmentCommand.vmaddr + segmentCommand.vmsize){
                        for j in segment.sections {
                            if (address >= j.info.addr && address < j.info.addr + j.info.size){
                                return j.info
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    
    
    func getOffsetFromVmAddress(_ address: UInt64) -> UInt64 {
        for i in self.commands {
            let type  = type(of: i)
            
            if (type == MachOLoadCommand.Segment.self){
                
                if  let segmentCommand =  (i as! MachOLoadCommand.Segment).command64 {
                    if (address >= segmentCommand.vmaddr && address <= segmentCommand.vmaddr + segmentCommand.vmsize){
                        return address - (segmentCommand.vmaddr - segmentCommand.fileoff)
                    }
                }
            }
        }
        return  0
    }
    
    
    
    func getMachoData() -> Data {
        return self.data
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
    
    func findSymbol(at value: UInt64) -> String {
        return "1"
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
        let header =  data.extract(mach_header_64.self)
        let dataSlice = data.cutoutData(mach_header_64.self)
        return MachOHeader(header: header, dataSlice: dataSlice)
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
    
    
    private static func loadSectionFlags(from data: Data, header: MachOHeader, attributes: MachAttributes) -> Dictionary<Int,Int> {
        
        var sectionDic :Dictionary<Int,Int> = [:]
        var sectionNum = 1
        var offset = header.size
        for _ in 0..<header.loadCommandCount {
            let loadCommand = MachOLoadCommand(data: data, offset: offset, byteSwapped: attributes.isByteSwapped)
            
            let type =   LoadCommandType(rawValue: loadCommand.command)
            if type == .segment || type == .segment64 {
                let segmentCommand64:segment_command_64 = loadCommand.data.extract(segment_command_64.self, offset: loadCommand.offset)
                
                let sectionOffset = loadCommand.offset + 0x48;
                
                for i in 0..<segmentCommand64.nsects {
                    let offset = sectionOffset + 0x50 * Int(i);
                    let sectionHeader:section_64 = loadCommand.data.extract(section_64.self, offset: offset)
                    sectionDic.updateValue(Int(sectionHeader.flags), forKey:sectionNum)
                    sectionNum += 1
                }
            }
            offset += Int(loadCommand.size)
        }
        return sectionDic
    }
}



