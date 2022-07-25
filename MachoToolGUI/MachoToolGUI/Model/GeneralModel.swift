//
//  GeneralModel.swift
//  MachoToolGUI
//
//  Created by karthrine on 2022/7/18.
//

import Foundation
import MachOTool
import MachO

/// 通用配置model 用于显示
/// 暂时记录的 后面会慢慢修改

public struct GeneralModel {
    public var name:String
    public var value:String
    public var offset:String? = nil
    public var data:String? = nil
    
    init(name :String, value:String, offset:String? = nil, data:String? = nil){
        self.name = name
        self.value = value
        self.offset = offset
        self.data = data
    }
}

public struct ExtraData{
    
}


public struct DisplayModel{
    var sourceDataRange: Range<Int>
    var extraList:ExtraData? = nil
}

 


/// 拼装GUI需要显示的数据
public struct Display {
    
    public static func machoHeaderDisplay(_ machoHeader:MachOHeader) -> [DisplayModel] {
        var headerList:[DisplayModel] = []
        
//        let magicTypeRange =  DataTool.absoluteRange(with: machoHeader.dataSlice, start:0, MemoryLayout<UInt32>.size)
//        headerList.append(DisplayModel(sourceDataRange: magicTypeRange, explanationItem: ExplanationItem(description: "File Magic", explanation: "\(machoHeader.magic)",extraDescription: "Data HEX",extraExplanation: machoHeader.magic.hex)))
//
//        let cpuTypeRange =  DataTool.absoluteRange(with: machoHeader.dataSlice, start:4, MemoryLayout<UInt32>.size)
//        headerList.append(DisplayModel(sourceDataRange: cpuTypeRange, explanationItem: ExplanationItem(description: "CPU Type", explanation: "\(machoHeader.cpuType)",extraDescription: "Data HEX",extraExplanation: UInt64(machoHeader.cputype).hex)))
//
//
//        let cpuSubTypeRange =  DataTool.absoluteRange(with: machoHeader.dataSlice, start:8, MemoryLayout<UInt32>.size)
//        headerList.append(DisplayModel(sourceDataRange: cpuSubTypeRange, explanationItem: ExplanationItem(description: "CPU SubType", explanation: "\(machoHeader.cpuSubtype)",extraDescription: "Data HEX",extraExplanation: UInt64(machoHeader.cpusubtype).hex)))
//
//
//        let nlcRange =  DataTool.absoluteRange(with: machoHeader.dataSlice, start:16, MemoryLayout<UInt32>.size)
//        headerList.append(DisplayModel(sourceDataRange: nlcRange, explanationItem: ExplanationItem(description: "Number of Load Commands", explanation: "\(machoHeader.loadCommandCount)",extraDescription: "Data HEX",extraExplanation: machoHeader.loadCommandCount.hex)))
//
//        let slcRange =  DataTool.absoluteRange(with: machoHeader.dataSlice, start:20, MemoryLayout<UInt32>.size)
//        headerList.append(DisplayModel(sourceDataRange: slcRange, explanationItem: ExplanationItem(description: "Size of Load Commands", explanation: "\(machoHeader.loadCommandSize)",extraDescription: "Data HEX",extraExplanation: machoHeader.loadCommandSize.hex)))
//
//
//        let flagRange =  DataTool.absoluteRange(with: machoHeader.dataSlice, start:24, MemoryLayout<UInt32>.size)
//        headerList.append(DisplayModel(sourceDataRange: flagRange, explanationItem: ExplanationItem(description: "Flag", explanation: "\(machoHeader.flags)",extraDescription: "Data HEX",extraExplanation: machoHeader.flags.hex)))
        
        return headerList
    }
    
    
    
    public static func loadCommondDisplay(_ loadCommand:MachOLoadCommandType) -> [ExplanationItem] {
        return loadCommand.displayStore.items
    }
    
//    public var cmdsize: UInt32 /* includes pathname string */

//    public var dylib: dylib /* the library identification */
    
//    public struct build_version_command {
//
//        public init()
//
//        public init(cmd: UInt32, cmdsize: UInt32, platform: UInt32, minos: UInt32, sdk: UInt32, ntools: UInt32)
//
//        public var cmd: UInt32 /* LC_BUILD_VERSION */
//
//        public var cmdsize: UInt32 /* sizeof(struct build_version_command) plus */
//
//        /* ntools * sizeof(struct build_tool_version) */
//        public var platform: UInt32 /* platform */
//
//        public var minos: UInt32 /* X.Y.Z is encoded in nibbles xxxx.yy.zz */
//
//        public var sdk: UInt32 /* X.Y.Z is encoded in nibbles xxxx.yy.zz */
//
//        public var ntools: UInt32 /* number of tool entries following this */
//    }
//
//
    
    
    
    
    
}









/// header 需要显示的
struct MachoSegMent {
    
    func exportMachoSegMentList(_ loadCommand:MachOLoadCommandType) -> [GeneralModel] {
        
        var headerList:[GeneralModel] = []
        
        let type  = type(of: loadCommand)
        if (type == MachOLoadCommand.Segment.self){
            let segment = loadCommand as! MachOLoadCommand.Segment
            
            headerList.append(GeneralModel(name: "Segment Name", value:segment.name))
            headerList.append(GeneralModel(name: "Command", value:"\(segment.command64!.cmd)"))
            headerList.append(GeneralModel(name: "Command Size", value:"\(segment.command64!.cmdsize)"))
            headerList.append(GeneralModel(name: "VM Address", value:"\(segment.command64!.vmaddr)"))
            headerList.append(GeneralModel(name: "VM Size", value:"\(segment.command64!.vmsize)"))
            headerList.append(GeneralModel(name: "File Offset", value:"\(segment.command64!.fileoff)"))
            headerList.append(GeneralModel(name: "File Size", value:"\(segment.command64!.filesize)"))
            headerList.append(GeneralModel(name: "Number of Sections", value:"\(segment.command64!.nsects)"))
            
            headerList.append(GeneralModel(name: "Maximum VM protection", value:"\(segment.command64!.maxprot)"))
            headerList.append(GeneralModel(name: "Initial VM protection", value:"\(segment.command64!.initprot)"))
        }
        
        return headerList
    }
    
}


struct MachoSYMTAB {
    func exportMachoSegMentList(_ loadCommand:MachOLoadCommandType) -> [GeneralModel] {
        
        var headerList:[GeneralModel] = []
        
        let type  = type(of: loadCommand)
        if (type == MachOLoadCommand.LC_SymbolTable.self){
            let command = loadCommand as! MachOLoadCommand.LC_SymbolTable
            headerList.append(GeneralModel(name: "Command", value:"\(command.command!.cmd)"))
            headerList.append(GeneralModel(name: "Command Size", value:"\(command.command!.cmdsize)"))
            headerList.append(GeneralModel(name: "Symbol Table Offset", value:"\(command.command!.symoff)"))
            headerList.append(GeneralModel(name: "Number of Symbols", value:"\(command.command!.nsyms)"))
            headerList.append(GeneralModel(name: "String Table Offset", value:"\(command.command!.stroff)"))
            headerList.append(GeneralModel(name: "String Table Size", value:"\(command.command!.strsize)"))
        }
        
        return headerList
    }
}


struct MachoDYSYMTAB{
    func exportMachoDYSYMTABList(_ loadCommand:MachOLoadCommandType) -> [GeneralModel] {
        
        var headerList:[GeneralModel] = []
        
        let type  = type(of: loadCommand)
        if (type == MachOLoadCommand.LC_DynamicSymbolTable.self){
            let command = loadCommand as! MachOLoadCommand.LC_DynamicSymbolTable
            
            headerList.append(GeneralModel(name: "Command", value:"\(command.command!.cmd)"))
            headerList.append(GeneralModel(name: "Command Size", value:"\(command.command!.cmdsize)"))
            
            headerList.append(GeneralModel(name: "LocSymbol Index", value:"\(command.command!.ilocalsym)"))
            headerList.append(GeneralModel(name: "LocSymbol Number", value:"\(command.command!.nlocalsym)"))
            
            headerList.append(GeneralModel(name: "Defined ExtSymbol Index", value:"\(command.command!.iextdefsym)"))
            headerList.append(GeneralModel(name: "Defined ExtSymbol Number", value:"\(command.command!.nextdefsym)"))
            
            headerList.append(GeneralModel(name: "Undef ExtSymbol Index", value:"\(command.command!.iundefsym)"))
            headerList.append(GeneralModel(name: "Undef ExtSymbol Number", value:"\(command.command!.nundefsym)"))
            
            headerList.append(GeneralModel(name: "TOC Offset", value:"\(command.command!.tocoff)"))
            headerList.append(GeneralModel(name: "Undef ExtSymbol Number", value:"\(command.command!.ntoc)"))
            
            headerList.append(GeneralModel(name: "Module Table Offset", value:"\(command.command!.modtaboff)"))
            headerList.append(GeneralModel(name: "Module Table Entries", value:"\(command.command!.nmodtab)"))
            
            headerList.append(GeneralModel(name: "ExtRef Table Offset", value:"\(command.command!.extrefsymoff)"))
            headerList.append(GeneralModel(name: "ExtRef Table Entries", value:"\(command.command!.nextrefsyms)"))
            
            headerList.append(GeneralModel(name: "IndSym Table Offset", value:"\(command.command!.indirectsymoff)"))
            headerList.append(GeneralModel(name: "IndSym Table Entries", value:"\(command.command!.nindirectsyms)"))
            
            headerList.append(GeneralModel(name: "ExtReloc Table Offset", value:"\(command.command!.extreloff)"))
            headerList.append(GeneralModel(name: "ExtReloc Table Entries", value:"\(command.command!.nextrel)"))
            
            headerList.append(GeneralModel(name: "LocReloc Table Offset", value:"\(command.command!.locreloff)"))
            headerList.append(GeneralModel(name: "LocReloc Table Entries", value:"\(command.command!.nlocrel)"))
        
        }
        
        return headerList
    }
}

