//
//  Macho.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/8.
//

import Foundation


class Macho : Equatable {
    static func == (lhs: Macho, rhs: Macho) -> Bool {
        return lhs.id == rhs.id
    }
    var is64bit = false
    let id = UUID()
    let data: DataSlice
    var fileSize: Int { data.count }
    let machoFileName: String
    let header: MachoHeader
    
    // 每个section的header 合集
    private(set) var sectionHeaders: [SectionHeader64] = []
    
    // 存放StringTable的信息
    var stringTableInterpretInfo: StringTableInterpretInfo?

    //存放SymbolTable的信息
    var symbolTableInterpretInfo: SymbolTableInterpretInfo?
     
    // 存放indirectSymbol的信息
    var indirectSymbolTableInterpreterInfo: IndirectSymbolTableInterpreterInfo?
    
    init(machoDataRaw:Data, machoFileName:String){
        let machoData = DataSlice(machoDataRaw)
        self.data = machoData
        self.machoFileName = machoFileName
        
        
        var loadCommands: [MachoComponent] = []
        
        guard let magicType = MagicType(machoData.raw) else {fatalError()}
        
        let is64bit = magicType == .macho64
        self.is64bit = is64bit
        
        // 获取machoHeader
        self.header = MachoHeader(from: machoData.interception(from: .zero, length: is64bit ? 32 : 28) , is64Bit: is64bit)
        
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
    
    
    func translationLoadCommands(with  loadCommandData:DataSlice , loadCommandType:LoadCommandType ) -> JYLoadCommand {
        
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
            let  interpreter = SymbolTableInterpreter()
         
            //用于存放符号表数据 [JYSymbolTableEntryModel]
            // 但是缺少symbolName,因为SymbolName存放在stringTable,
            // n_strx + 字符串表的起始位置 =  符号名称
            self.symbolTableInterpretInfo  = interpreter.symbolTableInterpreter(with: segment, is64Bit: is64bit, data: data)
            
            self.stringTableInterpretInfo = interpreter.stringTableInterpreter(with: segment, is64Bit: is64bit, data: data)
            
            return segment
            
        case .dynamicSymbolTable: //LC_DYSYMTAB
            /* symtab_command must be present when this load command is present */
            /* also we assume symtab_command locates before dysymtab_command */
            let segment =  DynamicSymbolTableCompont(with: loadCommandData, commandType: loadCommandType)
            let interpreter = IndirectSymbolTableInterpreter(with: data, is64Bit: is64bit, machoProtocol: self)
            self.indirectSymbolTableInterpreterInfo = interpreter.indirectSymbolTableInterpreter(from: segment)
            return segment
        
        case .buildVersion:
            let segment =   JYBuildVersionCommand(with: loadCommandData, commandType: loadCommandType)
            return segment
        default:
            return  JYLoadCommand(with: data, commandType: loadCommandType, translationStore: nil)
        }
        
    }
    
    
}




extension Macho : MachoProtocol {
    
    func indexInSymbolTable(at index: Int) -> JYSymbolTableEntryModel? {
        if let symbolTableInterpretInfo = self.symbolTableInterpretInfo {
            let symbolTableEntryModel =  symbolTableInterpretInfo.symbolTableList[index]
            return symbolTableEntryModel
        }
        return nil
    }
    
    
    // 查找字符串
    func stringInStringTable(at offset: Int) -> String? {
       let value =  self.stringTableInterpretInfo?.interpreter.findString(at: offset)
       return value
    }
    
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
