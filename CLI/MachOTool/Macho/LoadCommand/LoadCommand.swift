//
//  LoadCommand.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/24.
//

import Foundation
import MachO


 


let byteSwappedOrder = NXByteOrder(rawValue: 0)

public protocol MachOLoadCommandType {
    
    var name: String { get }
    var displayStore:DisplayStore { get }
}



public struct MachOLoadCommand {
    public var name: String
    public var displayStore: DisplayStore
    let data: Data
    let command: UInt32
    let size: Int
    let offset: Int
    let byteSwapped: Bool
     
    
    init(data: Data, offset: Int, byteSwapped: Bool) {
        var loadCommand = data.extract(load_command.self, offset: offset)
        if byteSwapped {
            swap_load_command(&loadCommand, byteSwappedOrder)
        }
        self.name = ""
        
        self.command = loadCommand.cmd
        self.size = Int(loadCommand.cmdsize)
        self.data = data
        self.offset = offset
        self.byteSwapped = byteSwapped
        
        let type =   LoadCommandType(rawValue: command)
        let dataSlice = DataTool.interception(with: data, from: offset, length: Int(loadCommand.cmdsize))
        let displayStore = DisplayStore(dataSlice: dataSlice)
        self.displayStore = displayStore
         
        
        displayStore.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: data, start: 0, 4), model: ExplanationModel(description: "Load Command Type", explanation:type?.name ?? "" )))
        
        displayStore.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: data, start: 4, 8), model: ExplanationModel(description: "Load Command Size", explanation:loadCommand.cmdsize.hex)))
        
    }
    
    func command(from data: Data, offset: Int, byteSwapped: Bool) -> MachOLoadCommandType? {
        
        let type =   LoadCommandType(rawValue: command)
        switch type {
            
        case .segment, .segment64 :
            return Segment(loadCommand: self)
            
        case .main :
            return LC_Main(loadCommand: self)
            
        case .dyldInfoOnly:
            return LC_DyldInfo(loadCommand: self)
        
        case .symbolTable:
            return LC_SymbolTable(loadCommand: self)
        
        case .sourceVersion:
            return LC_SourceVersion(loadCommand: self)
        
        case .dynamicSymbolTable:
            return LC_DynamicSymbolTable(loadCommand: self)
            
        case .rpath, .idDynamicLinker, .loadDynamicLinker, .dyldEnvironment:
            return LC_Rpath(loadCommand: self)
            
        case .uuid:
            return LC_Uuid(loadCommand: self)
            
        case .idDylib, .loadDylib, .loadWeakDylib, .reexportDylib, .lazyLoadDylib, .loadUpwardDylib:
            return LC_Load_Dylib(loadCommand: self)
            
        case .iOSMinVersion, .macOSMinVersion, .tvOSMinVersion, .watchOSMinVersion:
            return LC_MinOSVersion(loadCommand: self)
            
        case .encryptionInfo64,. encryptionInfo:
            return LC_EncryptionInfo(loadCommand: self)
            
        case .dataInCode, .codeSignature, .functionStarts, .segmentSplitInfo, .dylibCodeSigDRs, .linkerOptimizationHint, .dyldExportsTrie, .dyldChainedFixups:
            return LC_LinkeditCommand(loadCommand: self)

            
        default:
            return LC_Unknown(loadCommand: self)
        }
    }
}

 
