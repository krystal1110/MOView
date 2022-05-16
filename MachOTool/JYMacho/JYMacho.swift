//
//  JYMacho.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/8.
//

import Foundation


class JYMacho : Equatable {
    static func == (lhs: JYMacho, rhs: JYMacho) -> Bool {
        return lhs.id == rhs.id
    }
    var is64bit = false
    let id = UUID()
    let data: JYDataSlice
    var fileSize: Int { data.count }
    let machoFileName: String
    let header: JYMachoHeader
    
    // 每个section的header 合集
    private(set) var sectionHeaders: [JYSectionHeader64] = []
    
    init(machoDataRaw:Data, machoFileName:String){
        let machoData = JYDataSlice(machoDataRaw)
        self.data = machoData
        self.machoFileName = machoFileName
        
        
        var loadCommands: [JYMachoComponent] = []
        
        guard let magicType = MagicType(machoData.raw) else {fatalError()}
        
        let is64bit = magicType == .macho64
        self.is64bit = is64bit
        
        // 获取machoHeader
        self.header = JYMachoHeader(from: machoData.interception(from: .zero, length: is64bit ? 32 : 28) , is64Bit: is64bit)
        
        // header大小之后 就是 load_command
        var loadCommondsStartOffset = self.header.componentSize
        
        
        
        for _ in 0..<self.header.ncmds {
            //读取的Command
            let loadCommand: JYLoadCommand
            
            // 读取第一条load_command
            let loadCommandTypeRaw = self.data.interception(from: loadCommondsStartOffset, length: 4).raw.UInt32
            
            //command的类型
            guard let loadCommandType = LoadCommandType(rawValue: loadCommandTypeRaw) else {
                print("Unknown load command type \(loadCommandTypeRaw.hex). This must be a new one.")
                fatalError()
            }
            //command的大小
            let loadCommandSize = Int(machoData.interception(from: loadCommondsStartOffset + 4, length: 4).raw.UInt32)
            
            //comand的data
            let loadCommandData = machoData.interception(from: loadCommondsStartOffset, length: loadCommandSize)
            
            //下一个command的起始位置
            loadCommondsStartOffset += loadCommandSize
            
            loadCommand =  translationLoadCommands(with: loadCommandData, loadCommandType: loadCommandType)
            
            // 统一加到 Load Commands
            loadCommands.append(loadCommand)
        }
        
        
    }
    
    
    func translationLoadCommands(with  loadCommandData:JYDataSlice , loadCommandType:LoadCommandType ) -> JYLoadCommand {
        
        switch loadCommandType {
        case .segment, .segment64: //__PAGEZERO  __Text  __DATA  __LINKEDIT
            let segment =  JYSegment(with: loadCommandData, commandType: loadCommandType)
            let segmentHeader = segment.sectionHeaders
            self.sectionHeaders.append(contentsOf: segmentHeader)
           
            
            if segment.fileoff == 0 && segment.filesize != 0{
                // __TEXT段
                print(segment.segname)
            }
            return segment
       
        case .main:  // LC_Main
            let segment = JYMainCommand(with: loadCommandData, commandType: loadCommandType)
            return segment
        
        case .symbolTable: //LC_SYMTAB
            let segment = JYSymbolTableCommand(with: loadCommandData, commandType: loadCommandType)
            
//            let symbolTableComponent = symbolTableComponent(from: segment)
            let  interpreter = JYSymbolTableInterpreter()
            interpreter.symbolTableInterpreter(with: segment, is64Bit: is64bit, data: data)
            interpreter.stringTableInterpreter(with: segment, is64Bit: is64bit, data: data)
            
            return segment
            
        case .dynamicSymbolTable: //LC_DYSYMTAB
            /* symtab_command must be present when this load command is present */
            /* also we assume symtab_command locates before dysymtab_command */
            let segment =  JYDynamicSymbolTableCompont(with: loadCommandData, commandType: loadCommandType)
            
            #warning("TODO 解析动态符号表")
            return segment
        
        case .buildVersion:
            let segment =   JYBuildVersionCommand(with: loadCommandData, commandType: loadCommandType)
            return segment
        default:
            return  JYLoadCommand(with: data, commandType: loadCommandType, translationStore: nil)
        }
        
    }
    
    
}




extension JYMacho {
    fileprivate func symbolTableComponent(from symbolTableCommand: JYSymbolTableCommand)  {
        
        //起始位置
        let symbolTableStartOffset = Int(symbolTableCommand.symbolTableOffset)
       
        //有多少个符号
        let numberOfEntries = Int(symbolTableCommand.numberOfSymbolTable)
        
        let entrySize = is64bit ? 16 : 12

        //symbol长度
        let symbolSize = numberOfEntries * entrySize
        
        // symbol的data
        let symbolTableData = data.interception(from: symbolTableStartOffset, length: symbolSize)
        
 
        
    }
}
