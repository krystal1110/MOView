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
    let data:Data
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
    
    // 存储__TEXT,__ustring
    var uStringStoreInfo : UStringStoreInfo?
    
    // 存放indirectSymbol的信息
    var indirectSymbolTableStoreInfo: IndirectSymbolTableStoreInfo?
    
    
    
    var allBaseStoreInfoList: [BaseStoreInfo] = []
     
    
    
    init(machoDataRaw: Data, machoFileName: String) {
        data = machoDataRaw
        self.machoFileName = machoFileName
        
        var loadCommands: [MachoComponent] = []
        
        guard let magicType = MagicType(data) else { fatalError() }
        
        let is64bit = magicType == .macho64
        self.is64bit = is64bit
        
        // 获取machoHeader
        header = MachoHeader(from: DataTool.interception(with: data, from: .zero, length: is64bit ? 32 : 28), is64Bit: is64bit)
        
        // header大小之后 就是 load_command
        var loadCommondsStartOffset = header.componentSize
        
        for _ in 0 ..< header.ncmds {
            // 读取的Command
            let loadCommand: JYLoadCommand
            
            // 读取第一条load_command
            let loadCommandTypeRaw =  DataTool.interception(with: data, from: loadCommondsStartOffset, length: 4).UInt32
            
            // command的类型
            guard let loadCommandType = LoadCommandType(rawValue: loadCommandTypeRaw) else {
                print("Unknown load command type \(loadCommandTypeRaw.hex). This must be a new one.")
                fatalError()
            }
            // command的大小
             
            let loadCommandSize = Int(DataTool.interception(with: data, from: loadCommondsStartOffset + 4, length: 4).UInt32)
            
            // comand的data
            let loadCommandData = DataTool.interception(with: data, from: loadCommondsStartOffset, length: loadCommandSize)
            
            // 下一个command的起始位置
            loadCommondsStartOffset += loadCommandSize
            
            loadCommand = translationLoadCommands(with: loadCommandData, loadCommandType: loadCommandType)
            
            // 统一加到 Load Commands
            loadCommands.append(loadCommand)
        }
        
 
        // 加载对应的 section64
        let allBaseStoreInfoList = sectionHeaders.compactMap {self.machoComponent(from: $0)}
        self.allBaseStoreInfoList = allBaseStoreInfoList
        
        
        UnusedScanManager.init(with: self)
        
    }
    
    func translationLoadCommands(with loadCommandData: Data, loadCommandType: LoadCommandType) -> JYLoadCommand {
        switch loadCommandType {
        case .segment, .segment64: // __PAGEZERO  __Text  __DATA  __LINKEDIT
            let segment = JYSegment(with: loadCommandData, commandType: loadCommandType)
            let segmentHeaders = segment.sectionHeaders
            sectionHeaders.append(contentsOf: segmentHeaders)
            
            if segment.fileoff == 0, segment.filesize != 0 {
                // __TEXT段
//                print(segment.segname)
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
            let symbolTableStoreInfo = interpreter.symbolTableInterpreter(with: data, is64Bit: is64bit, symbolTableCommand: segment)
            self.symbolTableStoreInfo = symbolTableStoreInfo
           
            
            let stringTableStoreInfo = interpreter.stringTableInterpreter(with: data, is64Bit: is64bit, machoProtocol: self, symbolTableCommand: segment)
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
            
            
        case .dyldInfo, .dyldInfoOnly:
            let dyldInfo = DyldInfoCommand(with: loadCommandData, commandType: loadCommandType)
//            let dyldInfoComponents =
            let dyldInfoCompoents = dyldInfoComponts(wiht: dyldInfo)
            #warning("TODO")
            return JYLoadCommand(with: data, commandType: loadCommandType, translationStore: nil)
            
        case .buildVersion:
            let segment = JYBuildVersionCommand(with: loadCommandData, commandType: loadCommandType)
            return segment
        default:
            return JYLoadCommand(with: data, commandType: loadCommandType, translationStore: nil)
        }
    }
    
    
    /*
     *
     */
    fileprivate func machoComponent(from sectionHeader: SectionHeader64) -> BaseStoreInfo? {
        let componentTitle = "Section"
        let componentSubTitle = sectionHeader.segment + "," + sectionHeader.section
        
        
        switch sectionHeader.sectionType {
            /*
             __TEXT,__cstring    __TEXT,__objc_classname   __TEXT,__objc_methtype 均会来到此处
             因为都是存储的都为字符串类型
             **/
        case .S_CSTRING_LITERALS:
            let dataSlice = DataTool.interception(with: data, from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
            let cStringInterpreter = StringInterpreter(with: dataSlice, is64Bit: is64bit, machoProtocol: self, sectionVirtualAddress: sectionHeader.addr)
            let cStringTableList = cStringInterpreter.generatePayload()
            let info = StringTableStoreInfo(with: dataSlice,
                                            is64Bit: is64bit,
                                            interpreter: cStringInterpreter,
                                            title: componentTitle,
                                            subTitle: componentSubTitle,
                                            sectionVirtualAddress: sectionHeader.addr,
                                            stringTableList: cStringTableList)
            
            allCstringInterpretInfo.append(info)
            return info
            
            /*
             __DATA,__got ->  Non-Lazy Symbol Pointers
             __DATA,__la_symbol_ptr -> Lazy Symbol Pointers
             解析非懒加载和懒加载符号表
             拿到对应的Secton64 -> DATA段
             **/
        case .S_LAZY_SYMBOL_POINTERS, .S_NON_LAZY_SYMBOL_POINTERS, .S_LAZY_DYLIB_SYMBOL_POINTERS:
            
            let dataSlice = DataTool.interception(with: data, from:  Int(sectionHeader.offset), length: Int(sectionHeader.size))
            let symbolStoreInfo = LazySymbolInterpreter(with: dataSlice, is64Bit: is64bit, machoProtocol: self, sectionVirtualAddress: sectionHeader.addr, sectionType: sectionHeader.sectionType, startIndexInIndirectSymbolTable: Int(sectionHeader.reserved1)).transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
            return symbolStoreInfo
        case .S_REGULAR:
            /*
             _DATA_cfstring  -> objc CFStrings
             **/
            if (componentSubTitle == "__DATA,__cfstring"){
                 // 存储 Objective C 字符串的元数据
                let dataSlice = DataTool.interception(with: data, from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
                let cStringStoreInfo = CFStringInterpreter(wiht: dataSlice, is64Bit: is64bit, machoProtocol: self,sectionVirtualAddress: sectionHeader.addr).transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
                return cStringStoreInfo
            }else if (componentSubTitle == "__DATA,__objc_classrefs"){
                
                let dataSlice = DataTool.interception(with: data, from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
                let referencesInterpreter = ClassRefsInterpreter(wiht:dataSlice, is64Bit: self.is64bit, machoProtocol: self, sectionVirtualAddress: sectionHeader.addr)
                let referencesStoreInfo = referencesInterpreter.transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
                return referencesStoreInfo
            }
            
            else if (componentSubTitle == "__DATA,__objc_classlist"){
                // 解析classList
                let dataSlice = DataTool.interception(with: data, from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
                let referencesInterpreter = ReferencesInterpreter(wiht:dataSlice, is64Bit: self.is64bit, machoProtocol: self, sectionVirtualAddress: sectionHeader.addr)
                let referencesStoreInfo = referencesInterpreter.transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
                return referencesStoreInfo
            }
            
            else if (componentSubTitle == "__DATA,__objc_superrefs"){
                let dataSlice = DataTool.interception(with: data, from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
                let referencesInterpreter = ReferencesInterpreter(wiht:dataSlice, is64Bit: self.is64bit, machoProtocol: self, sectionVirtualAddress: sectionHeader.addr)
                let referencesStoreInfo = referencesInterpreter.transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
                return referencesStoreInfo
            }
            
            else if (componentSubTitle == "__DATA,__objc_catlist"){
                // __category_list 分类
                let dataSlice = DataTool.interception(with: data, from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
                let referencesInterpreter = ReferencesInterpreter(wiht:dataSlice, is64Bit: self.is64bit, machoProtocol: self, sectionVirtualAddress: sectionHeader.addr)
                let referencesStoreInfo = referencesInterpreter.transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
                return referencesStoreInfo
            }
            else if (componentSubTitle == "__DATA,__objc_nlcatlist"){
                // __category_list +load 分类
                let dataSlice = DataTool.interception(with: data, from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
                let referencesInterpreter = ReferencesInterpreter(wiht:dataSlice, is64Bit: self.is64bit, machoProtocol: self, sectionVirtualAddress: sectionHeader.addr)
                let referencesStoreInfo = referencesInterpreter.transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
                return referencesStoreInfo
            }
            
            else if (componentSubTitle == "__DATA,__objc_protolist"){
                // __protocol_list 协议
                let dataSlice = DataTool.interception(with: data, from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
                let referencesInterpreter = ReferencesInterpreter(wiht:dataSlice, is64Bit: self.is64bit, machoProtocol: self, sectionVirtualAddress: sectionHeader.addr)
                let referencesStoreInfo = referencesInterpreter.transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
                return referencesStoreInfo
            }
            
            else if (componentSubTitle == "__DATA,__objc_nlclslist"){
                // +load 协议
                let dataSlice = DataTool.interception(with: data, from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
                let referencesInterpreter = ReferencesInterpreter(wiht:dataSlice, is64Bit: self.is64bit, machoProtocol: self, sectionVirtualAddress: sectionHeader.addr)
                let referencesStoreInfo = referencesInterpreter.transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
                return referencesStoreInfo
            }
            
            else if (componentSubTitle == "__TEXT,__ustring"){
                let dataSlice = DataTool.interception(with: data, from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
                let uStringStoreInfo  = UStringInterpreter(with:dataSlice, is64Bit:self.is64bit, machoProtocol: self,sectionVirtualAddress: sectionHeader.addr).transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
                self.uStringStoreInfo = uStringStoreInfo
                return uStringStoreInfo
            }
            
            else if (componentSubTitle == "__TEXT,__swift5_reflstr"){
                let dataSlice = DataTool.interception(with: data, from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
                let cStringInterpreter = StringInterpreter(with: dataSlice, is64Bit: is64bit, machoProtocol: self, sectionVirtualAddress: sectionHeader.addr)
                let cStringTableList = cStringInterpreter.generatePayload()
                let reflstrStoreInfo = StringTableStoreInfo(with: dataSlice,
                                                is64Bit: is64bit,
                                                interpreter: cStringInterpreter,
                                                title: componentTitle,
                                                subTitle: componentSubTitle,
                                                sectionVirtualAddress: sectionHeader.addr,
                                                stringTableList: cStringTableList)
                return reflstrStoreInfo
            }
            
            else if (componentSubTitle == "__TEXT,__swift5_types"){
                let dataSlice = DataTool.interception(with: data, from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
                
                let fileOffset: Int64 = Int64(sectionHeader.offset);
                let swiftTypesInterpreter = SwiftTypesInterpreter(with: dataSlice, is64Bit: is64bit, machoProtocol: self, sectionVirtualAddress: sectionHeader.addr , machoData:self.data).loadData(fileOffset)
                 
            }else if (componentSubTitle == "__TEXT,__const"){
                // 存储的是swift 类的结构描述  也就是ClassContextDescriptor
//                print("----")
//                Section64(__TEXT,__const)
            }

            
            return nil
            
            
        case .S_LITERAL_POINTERS:
            // __DATA,__objc_selrefs
            let dataSlice = DataTool.interception(with: data, from: Int(sectionHeader.offset), length: Int(sectionHeader.size))
            let referencesInterpreter = ReferencesInterpreter(wiht:dataSlice, is64Bit: self.is64bit, machoProtocol: self ,sectionVirtualAddress: sectionHeader.addr)
            let referencesStoreInfo = referencesInterpreter.transitionStoreInfo(title: componentTitle, subTitle: componentSubTitle)
            return referencesStoreInfo
            
            
        default:
            break
        }
        
        return nil
    }
    
    
    
    func dyldInfoComponts(wiht command:DyldInfoCommand){
        
        /*
         处理rebase数据
         **/
        let rebaseInfoStart = Int(command.rebaseOffset)
        let rebaseInfoSize = Int(command.rebaseSize)
        if rebaseInfoStart.isNotZero && rebaseInfoSize.isNotZero { // 非空判断
            let rebaseInfoData = DataTool.interception(with: data, from: rebaseInfoStart, length: rebaseInfoSize)
//            DyldInterpreter.init(wiht: <#T##Data#>, is64Bit: <#T##Bool#>, machoProtocol: <#T##MachoProtocol#>, sectionVirtualAddress: <#T##UInt64#>)
        }
        
        
        
        /*
         处理bind数据
         **/
        let bindInfoStart = Int(command.bindOffset)
        let bindInfoSize = Int(command.bindSize)
        if bindInfoStart.isNotZero && bindInfoSize.isNotZero { // 非空判断
            let bindInfoData = DataTool.interception(with: data, from: bindInfoStart, length: bindInfoSize)
            let interpreter = DyldInterpreter.init(wiht: bindInfoData, is64Bit: is64bit, machoProtocol: self).operationCodes()
        }
        
        
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
        
        if (self.uStringStoreInfo != nil){
                for item in self.uStringStoreInfo!.uStringPositionList {
                  let itemVirtualAddress =  Int(self.uStringStoreInfo!.interpreter.sectionVirtualAddress) + item.relativeStartOffset
                    if (itemVirtualAddress == virtualAddress){
                        return item.explanationItem?.model.explanation
                    }
                }
        }
        for stringTableStoreInfo in self.allCstringInterpretInfo {
            // 判断区间范围
            if virtualAddress >= stringTableStoreInfo.interpreter.sectionVirtualAddress
                && virtualAddress < (stringTableStoreInfo.interpreter.sectionVirtualAddress + UInt64(stringTableStoreInfo.interpreter.data.count)) {
                return stringTableStoreInfo.interpreter.findString(with: virtualAddress, stringPositionList: stringTableStoreInfo.stringTableList)
            }
        }
        return nil
    }
}
