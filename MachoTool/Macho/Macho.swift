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

        #warning("TODO存储")
        // 加载对应的 section64
        let stringInterpretInfo = sectionHeaders.compactMap { self.machoComponent(from: $0) }
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
            symbolTableStoreInfo = interpreter.symbolTableInterpreter(with: segment, is64Bit: is64bit, data: data)

            stringTableStoreInfo = interpreter.stringTableInterpreter(with: segment, is64Bit: is64bit, data: data)

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
