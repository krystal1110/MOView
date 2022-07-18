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

struct GeneralModel {
    var name:String
    var value:String
    var offset:String? = nil
    var data:String? = nil
    
    init(name :String, value:String, offset:String? = nil, data:String? = nil){
        self.name = name
        self.value = value
        self.offset = offset
        self.data = data
    }
}



/// header 需要显示的
struct MachoHeaderDisplay {
    
    func exportMachoHeaderList(_ machoHeader:MachOHeader) -> [GeneralModel] {
        var headerList:[GeneralModel] = []
        headerList.append(GeneralModel(name: "File Magic", value: machoHeader.magicType, data: "\(machoHeader.magic)"))
        headerList.append(GeneralModel(name: "CPU Type", value: machoHeader.cpuType, data: "\(machoHeader.cputype)"))
        headerList.append(GeneralModel(name: "CPU SubType", value: machoHeader.cpuSubtype, data: "\(machoHeader.cpusubtype)"))
        headerList.append(GeneralModel(name: "Number of Load Commands", value: "\(machoHeader.loadCommandCount)"))
        headerList.append(GeneralModel(name: "Size of Load Commands", value: "\(machoHeader.loadCommandSize)"))
        headerList.append(GeneralModel(name: "Flag", value: "\(machoHeader.flags)"))
        return headerList
    }
    
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
 
