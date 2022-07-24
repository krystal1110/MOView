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
        else if (type == MachOLoadCommand.LC_SymbolTable.self){
            
            let symtab = loadCommand as! MachOLoadCommand.LC_SymbolTable
            let types =   LoadCommandType(rawValue: symtab.command!.cmd)
            let cmdRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:0, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: cmdRange, explanationItem: ExplanationItem(description: "Command", explanation: "\(types!.name)",extraDescription: "Data HEX",extraExplanation:symtab.command!.cmd.hex)))
            
            let cmdSizeRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:4, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: cmdSizeRange, explanationItem: ExplanationItem(description: "Command Size", explanation: "\(symtab.command!.cmdsize)",extraDescription: "Data HEX",extraExplanation:symtab.command!.cmdsize.hex)))
            
            let symtaboffRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:8, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: symtaboffRange, explanationItem: ExplanationItem(description: "Symbol Table Offset", explanation: "\(symtab.command!.symoff)",extraDescription: "Data HEX",extraExplanation:symtab.command!.symoff.hex)))
            
            let numofsymRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:12, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: numofsymRange, explanationItem: ExplanationItem(description: "Number of Symbols", explanation: "\(symtab.command!.nsyms)",extraDescription: "Data HEX",extraExplanation:symtab.command!.nsyms.hex)))
            
            let stringtabRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:16, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: stringtabRange, explanationItem: ExplanationItem(description: "String Table Offset", explanation: "\(symtab.command!.stroff)",extraDescription: "Data HEX",extraExplanation:symtab.command!.stroff.hex)))
            
            let stringtabsizeRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:16, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: stringtabsizeRange, explanationItem: ExplanationItem(description: "String Table Size", explanation: "\(symtab.command!.strsize)",extraDescription: "Data HEX",extraExplanation:symtab.command!.strsize.hex)))
        }
        else if (type == MachOLoadCommand.LC_DynamicSymbolTable.self){
            
            let symtab = loadCommand as! MachOLoadCommand.LC_DynamicSymbolTable
            let types =   LoadCommandType(rawValue: symtab.command!.cmd)
            let cmdRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:0, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: cmdRange, explanationItem: ExplanationItem(description: "Command", explanation: "\(types!.name)",extraDescription: "Data HEX",extraExplanation:symtab.command!.cmd.hex)))
            
            let cmdSizeRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:4, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: cmdSizeRange, explanationItem: ExplanationItem(description: "Command Size", explanation: "\(symtab.command!.cmdsize)",extraDescription: "Data HEX",extraExplanation:symtab.command!.cmdsize.hex)))
            
            let locsymIndexRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:8, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: locsymIndexRange, explanationItem: ExplanationItem(description: "LocSymbol Index", explanation: "\(symtab.command!.ilocalsym)",extraDescription: "Data HEX",extraExplanation:symtab.command!.ilocalsym.hex)))
            
            
            let nlocalsymRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:12, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: nlocalsymRange, explanationItem: ExplanationItem(description: "Number of Local Symbols", explanation: "\(symtab.command!.nlocalsym)",extraDescription: "Data HEX",extraExplanation:symtab.command!.nlocalsym.hex)))
            
            
            
            let iextdefsymRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:16, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: iextdefsymRange, explanationItem: ExplanationItem(description: "Defined ExtSymbol Index", explanation: "\(symtab.command!.iextdefsym)",extraDescription: "Data HEX",extraExplanation:symtab.command!.iextdefsym.hex)))
            
            let nextdefsymRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:20, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: nextdefsymRange, explanationItem: ExplanationItem(description: "Defined ExtSymbol Number", explanation: "\(symtab.command!.nextdefsym)",extraDescription: "Data HEX",extraExplanation:symtab.command!.nextdefsym.hex)))
            
            
            let iundefsymRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:24, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: iundefsymRange, explanationItem: ExplanationItem(description: "Undef ExtSymbol Index", explanation: "\(symtab.command!.iundefsym)",extraDescription: "Data HEX",extraExplanation:symtab.command!.iundefsym.hex)))
            
             

            let nundefsymRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:28, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: nundefsymRange, explanationItem: ExplanationItem(description: "Undef ExtSymbol Number", explanation: "\(symtab.command!.nundefsym)",extraDescription: "Data HEX",extraExplanation:symtab.command!.nundefsym.hex)))
            
             

            let tocoffRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:32, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: tocoffRange, explanationItem: ExplanationItem(description: "TOC Offset", explanation: "\(symtab.command!.tocoff)",extraDescription: "Data HEX",extraExplanation:symtab.command!.tocoff.hex)))
            
            let ntocRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:36, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: ntocRange, explanationItem: ExplanationItem(description: "TOC Entries", explanation: "\(symtab.command!.ntoc)",extraDescription: "Data HEX",extraExplanation:symtab.command!.ntoc.hex)))
            
            
            let modtaboffRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:40, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: modtaboffRange, explanationItem: ExplanationItem(description: "Module Table Offset", explanation: "\(symtab.command!.modtaboff)",extraDescription: "Data HEX",extraExplanation:symtab.command!.modtaboff.hex)))
            
            
            let nmodtabRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:44, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: nmodtabRange, explanationItem: ExplanationItem(description: "Module Table Entries", explanation: "\(symtab.command!.nmodtab)",extraDescription: "Data HEX",extraExplanation:symtab.command!.nmodtab.hex)))
            
            
            let extrefsymoffRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:48, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: extrefsymoffRange, explanationItem: ExplanationItem(description: "ExtRef Table Offset", explanation: "\(symtab.command!.extrefsymoff)",extraDescription: "Data HEX",extraExplanation:symtab.command!.extrefsymoff.hex)))
            
            let nextrefsymsRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:52, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: nextrefsymsRange, explanationItem: ExplanationItem(description: "ExtRef Table Entries", explanation: "\(symtab.command!.nextrefsyms)",extraDescription: "Data HEX",extraExplanation:symtab.command!.nextrefsyms.hex)))
            
            let indirectsymoffRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:56, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: indirectsymoffRange, explanationItem: ExplanationItem(description: "IndSym Table Offset", explanation: "\(symtab.command!.indirectsymoff)",extraDescription: "Data HEX",extraExplanation:symtab.command!.indirectsymoff.hex)))
            
             

            let nindirectsymsRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:60, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: nindirectsymsRange, explanationItem: ExplanationItem(description: "IndSym Table Entries", explanation: "\(symtab.command!.nindirectsyms)",extraDescription: "Data HEX",extraExplanation:symtab.command!.nindirectsyms.hex)))
             
            
            let extreloffRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:64, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: extreloffRange, explanationItem: ExplanationItem(description: "ExtReloc Table Offset", explanation: "\(symtab.command!.extreloff)",extraDescription: "Data HEX",extraExplanation:symtab.command!.extreloff.hex)))
            
            let nextrelRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:68, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: nextrelRange, explanationItem: ExplanationItem(description: "ExtReloc Table Entries", explanation: "\(symtab.command!.nextrel)",extraDescription: "Data HEX",extraExplanation:symtab.command!.nextrel.hex)))
            
            let locreloffRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:72, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: locreloffRange, explanationItem: ExplanationItem(description: "LocReloc Table Offset", explanation: "\(symtab.command!.locreloff)",extraDescription: "Data HEX",extraExplanation:symtab.command!.locreloff.hex)))
            
            let nlocrelRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:76, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: nlocrelRange, explanationItem: ExplanationItem(description: "LocReloc Table Entries", explanation: "\(symtab.command!.nlocrel)",extraDescription: "Data HEX",extraExplanation:symtab.command!.nlocrel.hex)))
        }
        else if (type == MachOLoadCommand.LC_Uuid.self){
            
            let symtab = loadCommand as! MachOLoadCommand.LC_Uuid
            let types =   LoadCommandType(rawValue: symtab.command!.cmd)
            let cmdRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:0, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: cmdRange, explanationItem: ExplanationItem(description: "Command", explanation: "\(types!.name)",extraDescription: "Data HEX",extraExplanation:symtab.command!.cmd.hex)))
            
            let cmdSizeRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:4, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: cmdSizeRange, explanationItem: ExplanationItem(description: "Command Size", explanation: "\(symtab.command!.cmdsize)",extraDescription: "Data HEX",extraExplanation:symtab.command!.cmdsize.hex)))
            
            let uuIDRange =  DataTool.absoluteRange(with: symtab.dataSlice, start:8, 16)
            list.append(DisplayModel(sourceDataRange: uuIDRange, explanationItem: ExplanationItem(description: "UUID", explanation: "\(symtab.uuid)")))
        }
        else if (type == MachOLoadCommand.LC_Version.self){
            
            let version = loadCommand as! MachOLoadCommand.LC_Version
            let types =   LoadCommandType(rawValue: version.command!.cmd)
            let cmdRange =  DataTool.absoluteRange(with: version.dataSlice, start:0, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: cmdRange, explanationItem: ExplanationItem(description: "Command", explanation: "\(types!.name)",extraDescription: "Data HEX",extraExplanation:version.command!.cmd.hex)))
            
            let cmdSizeRange =  DataTool.absoluteRange(with: version.dataSlice, start:4, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: cmdSizeRange, explanationItem: ExplanationItem(description: "Command Size", explanation: "\(version.command!.cmdsize)",extraDescription: "Data HEX",extraExplanation:version.command!.cmdsize.hex)))
            
            let versionRange =  DataTool.absoluteRange(with: version.dataSlice, start:8, 16)
            list.append(DisplayModel(sourceDataRange: versionRange, explanationItem: ExplanationItem(description: "Source Version", explanation: version.version)))
        }
        else if (type == MachOLoadCommand.LC_Main.self){
            
            let main = loadCommand as! MachOLoadCommand.LC_Main
            let types =   LoadCommandType(rawValue: main.command!.cmd)
            let cmdRange =  DataTool.absoluteRange(with: main.dataSlice, start:0, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: cmdRange, explanationItem: ExplanationItem(description: "Command", explanation: "\(types!.name)",extraDescription: "Data HEX",extraExplanation:main.command!.cmd.hex)))
            
            let cmdSizeRange =  DataTool.absoluteRange(with: main.dataSlice, start:4, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: cmdSizeRange, explanationItem: ExplanationItem(description: "Command Size", explanation: "\(main.command!.cmdsize)",extraDescription: "Data HEX",extraExplanation:main.command!.cmdsize.hex)))
            
            let entryoffRange =  DataTool.absoluteRange(with: main.dataSlice, start:8, 4)
            list.append(DisplayModel(sourceDataRange: entryoffRange, explanationItem: ExplanationItem(description: "Entry Offset", explanation: "\(main.command!.entryoff)")))
            
            let stacksizeRange =  DataTool.absoluteRange(with: main.dataSlice, start:12, 4)
            list.append(DisplayModel(sourceDataRange: stacksizeRange, explanationItem: ExplanationItem(description: "StackSize", explanation: "\(main.command!.stacksize)")))
        }
        else if (type == MachOLoadCommand.LC_Rpath.self){
            
            let rpath = loadCommand as! MachOLoadCommand.LC_Rpath
            let types =   LoadCommandType(rawValue: rpath.command!.cmd)
            let cmdRange =  DataTool.absoluteRange(with: rpath.dataSlice, start:0, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: cmdRange, explanationItem: ExplanationItem(description: "Command", explanation: "\(types!.name)",extraDescription: "Data HEX",extraExplanation:rpath.command!.cmd.hex)))
            
            let cmdSizeRange =  DataTool.absoluteRange(with: rpath.dataSlice, start:4, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: cmdSizeRange, explanationItem: ExplanationItem(description: "Command Size", explanation: "\(rpath.command!.cmdsize)",extraDescription: "Data HEX",extraExplanation:rpath.command!.cmdsize.hex)))
            
            let entryoffRange =  DataTool.absoluteRange(with: rpath.dataSlice, start:8, 4)
            list.append(DisplayModel(sourceDataRange: entryoffRange, explanationItem: ExplanationItem(description: "Path Offset", explanation: "\(rpath.command!.path.offset)")))
            
            
            let straddress =  rpath.dataSlice.count - Int(rpath.command!.path.offset)
            let pathRange =  DataTool.absoluteRange(with: rpath.dataSlice, start:12, straddress)
            list.append(DisplayModel(sourceDataRange: pathRange, explanationItem: ExplanationItem(description: "Path", explanation: rpath.path ?? "")))
            
        }
        else if (type == MachOLoadCommand.LinkeditCommand.self){
            let linkedit = loadCommand as! MachOLoadCommand.LinkeditCommand
            let types =   LoadCommandType(rawValue: linkedit.command!.cmd)
            let cmdRange =  DataTool.absoluteRange(with: linkedit.dataSlice, start:0, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: cmdRange, explanationItem: ExplanationItem(description: "Command", explanation: "\(types!.name)",extraDescription: "Data HEX",extraExplanation:linkedit.command!.cmd.hex)))
            
            let cmdSizeRange =  DataTool.absoluteRange(with: linkedit.dataSlice, start:4, MemoryLayout<UInt32>.size)
            list.append(DisplayModel(sourceDataRange: cmdSizeRange, explanationItem: ExplanationItem(description: "Command Size", explanation: "\(linkedit.command!.cmdsize)",extraDescription: "Data HEX",extraExplanation:linkedit.command!.cmdsize.hex)))
            
            let dataoffRange =  DataTool.absoluteRange(with: linkedit.dataSlice, start:8, 4)
            list.append(DisplayModel(sourceDataRange: dataoffRange, explanationItem: ExplanationItem(description: "Data Offset", explanation: "\(linkedit.command!.dataoff)")))
            
            let datasizeRange =  DataTool.absoluteRange(with: linkedit.dataSlice, start:12, 4)
            list.append(DisplayModel(sourceDataRange: datasizeRange, explanationItem: ExplanationItem(description: "Data Size", explanation: "\(linkedit.command!.datasize)")))
        }
        return list
    }
    
    
    
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

