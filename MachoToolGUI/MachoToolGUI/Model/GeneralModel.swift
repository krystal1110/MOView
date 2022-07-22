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
    var explanationItem: ExplanationItem
    var extraList:ExtraData? = nil
}

struct ExplanationItem {
    let description: String // 描述
    let explanation: String // 解释
    let extDescription: String?
    let extExplanation: String?
    
    init(description: String,
         explanation: String,
         extraDescription: String? = nil,
         extraExplanation: String? = nil) {
        self.description = description
        self.explanation = explanation
        self.extDescription = extraDescription
        self.extExplanation = extraExplanation
    }
}



/// 拼装GUI需要显示的数据
public struct Display {
    
    public static func machoHeaderDisplay(_ machoHeader:MachOHeader) -> [DisplayModel] {
        var headerList:[DisplayModel] = []
        
        let magicTypeRange =  DataTool.absoluteRange(with: machoHeader.dataSlice, start:0, MemoryLayout<UInt32>.size)
        headerList.append(DisplayModel(sourceDataRange: magicTypeRange, explanationItem: ExplanationItem(description: "File Magic", explanation: "\(machoHeader.magic)",extraDescription: "Data HEX",extraExplanation: machoHeader.magic.hex)))
        
        let cpuTypeRange =  DataTool.absoluteRange(with: machoHeader.dataSlice, start:4, MemoryLayout<UInt32>.size)
        headerList.append(DisplayModel(sourceDataRange: cpuTypeRange, explanationItem: ExplanationItem(description: "CPU Type", explanation: "\(machoHeader.cpuType)",extraDescription: "Data HEX",extraExplanation: UInt64(machoHeader.cputype).hex)))
        
        
        let cpuSubTypeRange =  DataTool.absoluteRange(with: machoHeader.dataSlice, start:8, MemoryLayout<UInt32>.size)
        headerList.append(DisplayModel(sourceDataRange: cpuSubTypeRange, explanationItem: ExplanationItem(description: "CPU SubType", explanation: "\(machoHeader.cpuSubtype)",extraDescription: "Data HEX",extraExplanation: UInt64(machoHeader.cpusubtype).hex)))
        
        
        let nlcRange =  DataTool.absoluteRange(with: machoHeader.dataSlice, start:16, MemoryLayout<UInt32>.size)
        headerList.append(DisplayModel(sourceDataRange: nlcRange, explanationItem: ExplanationItem(description: "Number of Load Commands", explanation: "\(machoHeader.loadCommandCount)",extraDescription: "Data HEX",extraExplanation: machoHeader.loadCommandCount.hex)))
        
        let slcRange =  DataTool.absoluteRange(with: machoHeader.dataSlice, start:20, MemoryLayout<UInt32>.size)
        headerList.append(DisplayModel(sourceDataRange: slcRange, explanationItem: ExplanationItem(description: "Size of Load Commands", explanation: "\(machoHeader.loadCommandSize)",extraDescription: "Data HEX",extraExplanation: machoHeader.loadCommandSize.hex)))
        
        
        let flagRange =  DataTool.absoluteRange(with: machoHeader.dataSlice, start:24, MemoryLayout<UInt32>.size)
        headerList.append(DisplayModel(sourceDataRange: flagRange, explanationItem: ExplanationItem(description: "Flag", explanation: "\(machoHeader.flags)",extraDescription: "Data HEX",extraExplanation: machoHeader.flags.hex)))
        
        return headerList
    }
    
    
    
    public static func loadCommondDisplay(_ loadCommand:MachOLoadCommandType) -> [DisplayModel] {
        var list:[DisplayModel] = []
        
        let type  = type(of: loadCommand)
//        let type1 =   LoadCommandType(rawValue: loadCommand.cmd)
        if (type == MachOLoadCommand.Segment.self){
            let segment = loadCommand as! MachOLoadCommand.Segment
            
            let segnameRange =  DataTool.absoluteRange(with: segment.dataSlice, start:8, MemoryLayout<(CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar)>.size)
            list.append(DisplayModel(sourceDataRange: segnameRange, explanationItem: ExplanationItem(description: "Segment Name", explanation: segment.name,extraDescription: "Data HEX",extraExplanation:"")))
            
            
            let types =   LoadCommandType(rawValue: segment.command64!.cmd)
            let cmdRange =  DataTool.absoluteRange(with: segment.dataSlice, start:0, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: cmdRange, explanationItem: ExplanationItem(description: "Command", explanation: "\(types!.name)",extraDescription: "Data HEX",extraExplanation:segment.command64!.cmd.hex)))
            
            
            let cmdSizeRange =  DataTool.absoluteRange(with: segment.dataSlice, start:4, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: cmdSizeRange, explanationItem: ExplanationItem(description: "Command Size", explanation: "\(segment.command64!.cmdsize)",extraDescription: "Data HEX",extraExplanation:segment.command64!.cmdsize.hex)))
            
            
            let vmAddrRange =  DataTool.absoluteRange(with: segment.dataSlice, start:24, MemoryLayout<UInt64>.size)
            list.append(DisplayModel(sourceDataRange: vmAddrRange, explanationItem: ExplanationItem(description: "VM Address", explanation: "\(segment.command64!.vmaddr)",extraDescription: "Data HEX",extraExplanation:segment.command64!.vmaddr.hex)))
            
            
            let vmSizeRange =  DataTool.absoluteRange(with: segment.dataSlice, start:32, MemoryLayout<UInt64>.size)
            list.append(DisplayModel(sourceDataRange: vmSizeRange, explanationItem: ExplanationItem(description: "VM Size", explanation: "\(segment.command64!.vmsize)",extraDescription: "Data HEX",extraExplanation:segment.command64!.vmsize.hex)))
            
            
            let fileoffRange =  DataTool.absoluteRange(with: segment.dataSlice, start:40, MemoryLayout<UInt64>.size)
            list.append(DisplayModel(sourceDataRange: fileoffRange, explanationItem: ExplanationItem(description: "File Offset", explanation: "\(segment.command64!.fileoff)",extraDescription: "Data HEX",extraExplanation:segment.command64!.fileoff.hex)))
            
            
            let fileSizeRange =  DataTool.absoluteRange(with: segment.dataSlice, start:48, MemoryLayout<UInt64>.size)
            list.append(DisplayModel(sourceDataRange: fileSizeRange, explanationItem: ExplanationItem(description: "File Size", explanation: "\(segment.command64!.filesize)",extraDescription: "Data HEX",extraExplanation:segment.command64!.filesize.hex)))
            
            
            let maxprotRange =  DataTool.absoluteRange(with: segment.dataSlice, start:56, MemoryLayout<vm_prot_t>.size)
            list.append(DisplayModel(sourceDataRange: maxprotRange, explanationItem: ExplanationItem(description: "Maximum VM protection", explanation: "\(segment.command64!.maxprot)")))
            
            let initprotRange =  DataTool.absoluteRange(with: segment.dataSlice, start:60, MemoryLayout<vm_prot_t>.size)
            list.append(DisplayModel(sourceDataRange: initprotRange, explanationItem: ExplanationItem(description: "Initial VM protection", explanation: "\(segment.command64!.initprot)")))
            
            
            let nsectsRange =  DataTool.absoluteRange(with: segment.dataSlice, start:64, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: nsectsRange, explanationItem: ExplanationItem(description: "Number of Sections", explanation: "\(segment.command64!.nsects)",extraDescription: "Data HEX",extraExplanation:segment.command64!.nsects.hex)))
        }
        else if (type == MachOLoadCommand.LC_DyldInfo.self){
            
            let dyldInfo = loadCommand as! MachOLoadCommand.LC_DyldInfo
            let types =   LoadCommandType(rawValue: dyldInfo.command!.cmd)
            let cmdRange =  DataTool.absoluteRange(with: dyldInfo.dataSlice, start:0, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: cmdRange, explanationItem: ExplanationItem(description: "Command", explanation: "\(types!.name)",extraDescription: "Data HEX",extraExplanation:dyldInfo.command!.cmd.hex)))
            
            
            let cmdSizeRange =  DataTool.absoluteRange(with: dyldInfo.dataSlice, start:4, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: cmdSizeRange, explanationItem: ExplanationItem(description: "Command Size", explanation: "\(dyldInfo.command!.cmdsize)",extraDescription: "Data HEX",extraExplanation:dyldInfo.command!.cmdsize.hex)))
            
            
            
            let rebaseoffRange =  DataTool.absoluteRange(with: dyldInfo.dataSlice, start:8, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: rebaseoffRange, explanationItem: ExplanationItem(description: "File Offset To Rebase Info", explanation: "\(dyldInfo.command!.rebase_off)",extraDescription: "Data HEX",extraExplanation:dyldInfo.command!.rebase_off.hex)))
            
            
            let rebaseSizeRange =  DataTool.absoluteRange(with: dyldInfo.dataSlice, start:12, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: rebaseSizeRange, explanationItem: ExplanationItem(description: "Size Of Rebase Info", explanation: "\(dyldInfo.command!.rebase_size)",extraDescription: "Data HEX",extraExplanation:dyldInfo.command!.rebase_size.hex)))
            
            
            let bindoffRange =  DataTool.absoluteRange(with: dyldInfo.dataSlice, start:16, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: bindoffRange, explanationItem: ExplanationItem(description: "File Offset To Binding Info", explanation: "\(dyldInfo.command!.bind_off)",extraDescription: "Data HEX",extraExplanation:dyldInfo.command!.bind_off.hex)))
            
            let bindsizeRange =  DataTool.absoluteRange(with: dyldInfo.dataSlice, start:20, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: bindsizeRange, explanationItem: ExplanationItem(description: "Size Of Binding Info", explanation: "\(dyldInfo.command!.bind_size)",extraDescription: "Data HEX",extraExplanation:dyldInfo.command!.bind_size.hex)))
            
            let weakbindoffRange =  DataTool.absoluteRange(with: dyldInfo.dataSlice, start:24, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: weakbindoffRange, explanationItem: ExplanationItem(description: "File Offset To Weak Binding Info", explanation: "\(dyldInfo.command!.weak_bind_off)",extraDescription: "Data HEX",extraExplanation:dyldInfo.command!.weak_bind_off.hex)))
            
            
            let weakbindsizeRange =  DataTool.absoluteRange(with: dyldInfo.dataSlice, start:28, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: weakbindsizeRange, explanationItem: ExplanationItem(description: "Size Of Weak Binding Info", explanation: "\(dyldInfo.command!.weak_bind_size)",extraDescription: "Data HEX",extraExplanation:dyldInfo.command!.weak_bind_size.hex)))
            
        }
        return list
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

