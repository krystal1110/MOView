//
//  Macho.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/8.
//

import Foundation

class Macho: Equatable {
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
    var stringTableStoreInfo: StringTableStoreInfo?
    
    // 存放SymbolTable的信息
    var symbolTableStoreInfo: SymbolTableStoreInfo?
    
    // 存储section里面数据为Cstring类型
    var allCstringInterpretInfo: [StringTableStoreInfo] = []
    
    // 存放indirectSymbol的信息
    var indirectSymbolTableStoreInfo: IndirectSymbolTableStoreInfo?
    
    var allBaseStoreInfoList: [BaseStoreInfo] = []
     
    
    
    init(machoDataRaw: Data, machoFileName: String) {
        let machoData = DataSlice(machoDataRaw)
        data = machoData
        self.machoFileName = machoFileName
        
        var loadCommands: [MachoComponent] = []
        
        guard let magicType = MagicType(machoData.raw) else { fatalError() }
        
        let is64bit = magicType == .macho64
        self.is64bit = is64bit
        
        // 获取machoHeader
        header = MachoHeader(from: machoData.interception(from: .zero, length: is64bit ? 32 : 28), is64Bit: is64bit)
        
        // header大小之后 就是 load_command
        var loadCommondsStartOffset = header.componentSize
        
        for _ in 0 ..< header.ncmds {
            // 读取的Command
            let loadCommand: JYLoadCommand
            
            // 读取第一条load_command
            let loadCommandTypeRaw = data.interception(from: loadCommondsStartOffset, length: 4).raw.UInt32
            
            // command的类型
            guard let loadCommandType = LoadCommandType(rawValue: loadCommandTypeRaw) else {
                print("Unknown load command type \(loadCommandTypeRaw.hex). This must be a new one.")
                fatalError()
            }
            // command的大小
            let loadCommandSize = Int(machoData.interception(from: loadCommondsStartOffset + 4, length: 4).raw.UInt32)
            
            // comand的data
            let loadCommandData = machoData.interception(from: loadCommondsStartOffset, length: loadCommandSize)
            
            // 下一个command的起始位置
            loadCommondsStartOffset += loadCommandSize
            
            loadCommand = translationLoadCommands(with: loadCommandData, loadCommandType: loadCommandType)
            
            // 统一加到 Load Commands
            loadCommands.append(loadCommand)
        }
        
 
        // 加载对应的 section64
        let allBaseStoreInfoList = sectionHeaders.compactMap {self.machoComponent(from: $0)}
        self.allBaseStoreInfoList = allBaseStoreInfoList
    }
    
    func translationLoadCommands(with loadCommandData: DataSlice, loadCommandType: LoadCommandType) -> JYLoadCommand {
        switch loadCommandType {
        case .segment, .segment64: // __PAGEZERO  __Text  __DATA  __LINKEDIT
            let segment = JYSegment(with: loadCommandData, commandType: loadCommandType)
            let segmentHeaders = segment.sectionHeaders
            sectionHeaders.append(contentsOf: segmentHeaders)
            
            if segment.fileoff == 0, segment.filesize != 0 {
                // __TEXT段
                print(segment.segname)
            }
            return segment
            
        case .main: // LC_Main
            let segment = JYMainCommand(with: loadCommandData, commandType: loadCommandType)
            return segment
            
        case .symbolTable: // LC_SYMTAB
            let segment = JYSymbolTableCommand(with: loadCommandData, commandType: loadCommandType)
            let interpreter = SymbolTableInterpreter()
            
            // 用于存放符号表数据 [JYSymbolTableEntryModel]
            // 但是缺少symbolName,因为SymbolName存放在stringTable,
            // n_strx + 字符串表的起始位置 =  符号名称
            let symbolTableStoreInfo = interpreter.symbolTableInterpreter(with: segment, is64Bit: is64bit, data: data)
            self.symbolTableStoreInfo = symbolTableStoreInfo
            let stringTableStoreInfo = interpreter.stringTableInterpreter(with: segment, is64Bit: is64bit, data: data)
            self.stringTableStoreInfo = stringTableStoreInfo
            allCstringInterpretInfo.append(stringTableStoreInfo)
            return segment
            
        case .dynamicSymbolTable: // LC_DYSYMTAB
            /* symtab_command must be present when this load command is present */
            /* also we assume symtab_command locates before dysymtab_command */
            let segment = DynamicSymbolTableCompont(with: loadCommandData, commandType: loadCommandType)
            let interpreter = IndirectSymbolTableInterpreter(with: data, is64Bit: is64bit, machoProtocol: self)
            indirectSymbolTableStoreInfo = interpreter.indirectSymbolTableInterpreter(from: segment)
            return segment
            
        case .buildVersion:
            let segment = JYBuildVersionCommand(with: loadCommandData, commandType: loadCommandType)
            return segment
        default:
            return JYLoadCommand(with: data, commandType: loadCommandType, translationStore: nil)
        }
    }
    
    fileprivate func machoComponent(from sectionHeader: SectionHeader64) -> BaseStoreInfo? {
        let componentTitle = "Section"
        let componentSubTitle = sectionHeader.segment + "," + sectionHeader.section
 
        if (componentSubTitle == "__TEXT,__ustring"){
            print("---")
        }
        
        print(componentSubTitle)
        switch sectionHeader.sectionType {
            /*
             __TEXT,__cstring    __TEXT,__objc_classname   __TEXT,__objc_methtype 均会来到此处
             因为都是存储的都为字符串类型
             **/
        case .S_CSTRING_LITERALS:
            let dataSlice = data.interception(from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
            let cStringInterpreter = StringInterpreter(with: dataSlice, is64Bit: is64bit, sectionVirtualAddress: sectionHeader.addr, searchSouce: nil)
            let cStringTableList = cStringInterpreter.generatePayload()
            let info = StringTableStoreInfo(with: dataSlice,
                                            is64Bit: is64bit,
                                            interpreter: cStringInterpreter,
                                            stringTableList: cStringTableList,
                                            title: componentTitle,
                                            subTitle: componentSubTitle)
            
            allCstringInterpretInfo.append(info)
            return info
            
            /*
             __DATA,__got ->  Non-Lazy Symbol Pointers
             __DATA,__la_symbol_ptr -> Lazy Symbol Pointers
             解析非懒加载和懒加载符号表
             拿到对应的Secton64 -> DATA段
             **/
        case .S_LAZY_SYMBOL_POINTERS, .S_NON_LAZY_SYMBOL_POINTERS, .S_LAZY_DYLIB_SYMBOL_POINTERS:
            
            let dataSlice = data.interception(from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
            let symbolStoreInfo = LazySymbolInterpreter(wiht: dataSlice, is64Bit: is64bit, machoProtocol: self, sectionType: sectionHeader.sectionType, startIndexInIndirectSymbolTable: Int(sectionHeader.reserved1)).transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
            return symbolStoreInfo
            
            
            
            
 
        case .S_REGULAR:
            /*
             _DATA_cfstring  -> objc CFStrings
             **/
            if (componentSubTitle == "__DATA,__cfstring"){
                let dataSlice = data.interception(from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
                let cStringStoreInfo = CFStringInterpreter(wiht: dataSlice, is64Bit: is64bit, machoProtocol: self).transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
                return cStringStoreInfo
            }
            
            else if (componentSubTitle == "__DATA,__objc_classlist"){
                // 解析classList
                let dataSlice = data.interception(from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
                let referencesInterpreter = ReferencesInterpreter(wiht:dataSlice, is64Bit: self.is64bit, machoProtocol: self)
                let referencesStoreInfo = referencesInterpreter.transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
                return referencesStoreInfo
            }
            
            else if (componentSubTitle == "__DATA,__objc_superrefs"){
                let dataSlice = data.interception(from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
                let referencesInterpreter = ReferencesInterpreter(wiht:dataSlice, is64Bit: self.is64bit, machoProtocol: self)
                let referencesStoreInfo = referencesInterpreter.transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
                return referencesStoreInfo
            }
            
            else if (componentSubTitle == "__DATA,__objc_catlist"){
                // __category_list 分类
                let dataSlice = data.interception(from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
                let referencesInterpreter = ReferencesInterpreter(wiht:dataSlice, is64Bit: self.is64bit, machoProtocol: self)
                let referencesStoreInfo = referencesInterpreter.transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
                return referencesStoreInfo
            }
            
            else if (componentSubTitle == "__DATA,__objc_protolist"){
                // __protocol_list 协议
                let dataSlice = data.interception(from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
                let referencesInterpreter = ReferencesInterpreter(wiht:dataSlice, is64Bit: self.is64bit, machoProtocol: self)
                let referencesStoreInfo = referencesInterpreter.transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
                return referencesStoreInfo
            }
            
            else if (componentSubTitle == "__TEXT,__ustring"){
                let dataSlice = data.interception(from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
                let uStringStoreInfo  = UStringInterpreter(wiht:dataSlice, is64Bit:self.is64bit, machoProtocol: self).transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
                return uStringStoreInfo
            }
            
            else if (componentSubTitle == "__TEXT,__swift5_reflstr"){
                let dataSlice = data.interception(from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
                let cStringInterpreter = StringInterpreter(with: dataSlice, is64Bit: is64bit, sectionVirtualAddress: sectionHeader.addr, searchSouce: nil)
                let cStringTableList = cStringInterpreter.generatePayload()
                let reflstrStoreInfo = StringTableStoreInfo(with: dataSlice,
                                                is64Bit: is64bit,
                                                interpreter: cStringInterpreter,
                                                stringTableList: cStringTableList,
                                                title: componentTitle,
                                                subTitle: componentSubTitle)
                return reflstrStoreInfo
            }
            
            return nil
            
            
        case .S_LITERAL_POINTERS:
            // __DATA,__objc_classrefs -> Objc2 References
            let dataSlice = data.interception(from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
            let referencesInterpreter = ReferencesInterpreter(wiht:dataSlice, is64Bit: self.is64bit, machoProtocol: self)
            let referencesStoreInfo = referencesInterpreter.transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
            return referencesStoreInfo
            
            
        default:
            break
        }
        
        return nil
    }
}

extension Macho: MachoProtocol {
    func indexInIndirectSymbolTable(at index: Int) -> IndirectSymbolTableEntryModel? {
        if let indirectInterpreInfo = indirectSymbolTableStoreInfo {
            let indirectEntryModel = indirectInterpreInfo.indirectSymbolTableList[index]
            return indirectEntryModel
        }
        return nil
    }
    
    func indexInSymbolTable(at index: Int) -> JYSymbolTableEntryModel? {
        if let SymbolTableStoreInfo = self.symbolTableStoreInfo {
            if(index > SymbolTableStoreInfo.symbolTableList.count){return nil}
            let symbolTableEntryModel = SymbolTableStoreInfo.symbolTableList[index]
            return symbolTableEntryModel
        }
        return nil
    }
    
    // 查找字符串
    func stringInStringTable(at offset: Int) -> String? {
        let value = stringTableStoreInfo?.interpreter.findString(at: offset)
        return value
    }
    
    func searchStringInSymbolTable(by nValue:UInt64) -> String?{
        guard let symbolTableList = self.symbolTableStoreInfo?.symbolTableList else{return nil}
        for model in symbolTableList {
            if (nValue == model.nValue){
                return self.stringInStringTable(at: Int(model.indexInStringTable))
            }
        }
        return nil
    }
    
    
    
    func searchString(by virtualAddress: UInt64) -> String? {
        for stringTableStoreInfo in self.allCstringInterpretInfo {
            // 判断区间范围
            if virtualAddress >= stringTableStoreInfo.interpreter.sectionVirtualAddress
                && virtualAddress < (stringTableStoreInfo.interpreter.sectionVirtualAddress + UInt64(stringTableStoreInfo.interpreter.data.count)) {
                return stringTableStoreInfo.interpreter.findString(with: virtualAddress, stringPositionList: stringTableStoreInfo.stringTableList)
            }
        }
        
        
        
        
        return nil
    }
    
    
    fileprivate func symbolTableComponent(from symbolTableCommand: JYSymbolTableCommand) {
        // 起始位置
        let symbolTableStartOffset = Int(symbolTableCommand.symbolTableOffset)
        
        // 有多少个符号
        let numberOfEntries = Int(symbolTableCommand.numberOfSymbolTable)
        
        let entrySize = is64bit ? 16 : 12
        
        // symbol长度
        let symbolSize = numberOfEntries * entrySize
        
        // symbol的data
        let symbolTableData = data.interception(from: symbolTableStartOffset, length: symbolSize)
    }
}
