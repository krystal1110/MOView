//
//  SwiftTypesInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/13.
//

import Foundation


struct SwiftTypeModel{
    var name: String = ""
    var superClass: String? = ""
    var accessOffset: UInt64 = 0
    var fields: [SwiftTypeField]  = []// 存着变量名
}


struct SwiftTypeField {
    var varName: String // 变量
    var module: String  // 模块名
}



struct FieldRecord{
    let flags: UInt32
    let mangledTypeName: UInt32
    let fieldName: UInt32
};

struct FieldDescriptor{
    let mangledTypeName: Int32
    let superclass: Int32
    let kind: UInt16
    let fieldRecordSize: UInt16
    let numFields: UInt32
};


struct SwiftType {
    let flag: UInt32
    let parent: UInt32
}

struct SwiftMethod {
    let kind: UInt32
    let offset : UInt32
}

struct SwiftBaseType {
    let flag: UInt32
    let parent: UInt32
    let name: Int32
    let accessFunction: Int32
    let fieldDescriptor: Int32
};





struct SwiftTypesInterpreter: Interpreter {
    
    var dataSlice: Data
    
    var section: Section64?
    
    var searchProtocol: SearchProtocol
    
    let pointerLength: Int = 8
    
    var vm: UInt64 = 0
    
    let data: Data
    
    var swiftRefsSet: Set<String> = []
   
    var textConst:section_64?
    
    init(with data:Data , dataSlice: Data, section:Section64,  searchProtocol:SearchProtocol){
        self.data = data
        self.dataSlice = dataSlice
        self.section = section
        self.searchProtocol = searchProtocol
        
        self.vm = section.info.addr - UInt64(section.info.offset)
        
    }
    
    
    // 转换为 stroeInfo 存储信息
    mutating func transitionData()  -> [SwiftTypeModel] {
        
        var nominalList:[SwiftTypeModel] = [];
        
        let numberOfTypes = dataSlice.count / 4
        
        for i in 0..<numberOfTypes {
            
            let typeAddress = section!.info.addr +  UInt64(i * 4)
            let offset = searchProtocol.getOffsetFromVmAddress(typeAddress)
            let content = DataTool.interception(with: data, from: offset.toInt, length: 4).UInt32
            var vmAddress =  UInt64(content) + typeAddress
            correctAddress(&vmAddress)
            
           // 获取对应的 TEXT - Section64
            DispatchQueue.once(token: "getTEXTConst") {
                if let x =  searchProtocol.getTEXTConst(vmAddress){
                    textConst = x
                }
            }
            
            
            let typeOffset = searchProtocol.getOffsetFromVmAddress(vmAddress)
            
            let swiftType = data.extract(SwiftBaseType.self, offset: typeOffset.toInt)
            
            
            let nameOffsetContent = DataTool.interception(with: data, from: Int(typeOffset) + 2 * 4, length: 4).UInt32
            var nameOffset = typeOffset + 2 * 4 + UInt64(nameOffsetContent)
            
            if nameOffset > vm {nameOffset -= vm}
            
            /// 拿到类名
            var name = data.readCstring(at: nameOffset)
            
            var parentOffset = typeOffset + 1 * 4 + UInt64(swiftType.parent)
            if parentOffset > vm { parentOffset = parentOffset - vm}
            if invalidParent(parentOffset){continue}
            
            
            /// 拿到类型
            var kind = SwiftContextDescriptorFlags(swiftType.flag).kind
            if kind == .OpaqueType  {
                /// 屏蔽 swiftUI 的some
                continue
            }
            
            /// 获取 ParentName
            while (kind != .Module) {
                /// 获取Parent的类型
                let swiftParentType = data.extract(SwiftBaseType.self, offset: parentOffset.toInt)
                 kind = SwiftContextDescriptorFlags(swiftParentType.flag).kind
                if kind == .Unknow {
                    break
                }
                
                // 匿名 二进制布局如下：Flag(4B)+Parent(4B)+泛型签名（不定长）+mangleName(4B)
                var genericPlaceholder:Int8 = 0
                if kind == .Anonymous {
                    genericPlaceholder = addPlaceholderWithGeneric(parentOffset)
                }
                
                //匿名 没有mangleName，则放弃
                if (kind == .Anonymous && !((swiftParentType.flag & 0xFFFF) == 0x01) ) {
                    break
                }
                
                let offset = Int(parentOffset) + 2 * 4 + Int(genericPlaceholder)
                let parentNameContent: UInt32 = data.readU32(offset:offset)
                var parentNameOffset = UInt64(Int(parentOffset) + 2 * 4 + Int(parentNameContent) + Int(genericPlaceholder))
                if (parentNameOffset > vm) {parentNameOffset = parentNameOffset - UInt64(vm)}
                let parentName = data.readCstring(at: parentNameOffset)
                
                // 匿名
                if kind == .Anonymous {
                    name  = getTypeFromMangledName(parentName)
                    break
                }
                
                name = parentName + "." + name
                 
                let parentOffsetContent = DataTool.interception(with: data, from: Int(parentOffset) + 1 * 4, length: 4).UInt32
                parentOffset = parentOffset + 1 * 4 + UInt64(parentOffsetContent)
                if parentOffset > vm {parentOffset = parentOffset - vm}
                if invalidParent(parentOffset) {break}
                
            }
            
            
            
            
            let accessFuncContent = DataTool.interception(with: data, from: Int(typeOffset) + 3 * 4, length: 4).UInt32
            var accessFuncAddr = vmAddress + 3 * 4 + UInt64(accessFuncContent)
            correctAddress(&accessFuncAddr)
            let accessOffset = searchProtocol.getOffsetFromVmAddress(accessFuncAddr)
            
            
            
            
            
            /// 查找属性
            let  fieldDescriptorContent = swiftType.fieldDescriptor
            if fieldDescriptorContent == 0 {continue}
            var  fieldDescriptorAddress =  UInt64(fieldDescriptorContent) + UInt64(vmAddress) + 4 * 4
            correctAddress(&fieldDescriptorAddress)
            let fieldDescriptorOffset = searchProtocol.getOffsetFromVmAddress(UInt64(fieldDescriptorAddress))
            let fieldDescriptor = data.extract(FieldDescriptor.self, offset: Int(fieldDescriptorOffset))

            
            var superClassName = ""
            if fieldDescriptor.superclass != 0 {
                let superclassAddr = Int(fieldDescriptorAddress) + 4 * 1 + Int(fieldDescriptor.superclass)
                if let x =  parseSuperClass(UInt64(superclassAddr)){
                    superClassName = x
                }
            }

            var model = SwiftTypeModel()
            model.fields  =  dumpFieldDescriptor(fieldDescriptor, fieldDescriptorAddress: fieldDescriptorAddress)
            model.name = name
            model.superClass = superClassName
            model.accessOffset = accessOffset
            nominalList.append(model)
            
        }
        return nominalList
    }
    
    
    /// 解析 SuperClass
    private mutating func parseSuperClass(_ superclassAddr:UInt64 ) -> String?{
        
        let superClassOffset = searchProtocol.getOffsetFromVmAddress(superclassAddr)
        
        guard let firstStr =   data.readCString(from: Int(superClassOffset)) else{
             return nil
        }
        
        var superClassModule = ""

        if firstStr.hasPrefix("0x01"){
            superClassModule = findMangleTypeName0x1(UInt64(superClassOffset))
            swiftRefsSet.insert(superClassModule)
            return superClassModule
        }else if firstStr.hasPrefix("0x02"){
            superClassModule = findMangleTypeName0x2(UInt64(superClassOffset))
            swiftRefsSet.insert(superClassModule)
            return superClassModule
        }else{
            superClassModule = getTypeFromMangledName(firstStr)
             
            // 过滤掉 So9NSObject 等类型
            if superClassModule.hasPrefix("So") && superClassModule.count <= 13  && superClassModule.count >= 5{
                let index2 = superClassModule.index(superClassModule.startIndex, offsetBy: 3)
                let index3 = superClassModule.index(superClassModule.endIndex, offsetBy: -2)
                let sub4 = superClassModule[index2...index3]
                swiftRefsSet.insert(String(sub4))
                return String(sub4)
            }else{
                swiftRefsSet.insert(superClassModule)
                return superClassModule
            }
        }
        
    }
 
    
    
    /// dump 属性
    private mutating func dumpFieldDescriptor(_ fieldDescriptor: FieldDescriptor, fieldDescriptorAddress:UInt64 ) ->  [SwiftTypeField]{
        
        var fieldObjList: [SwiftTypeField] = []
        
        let numFields = fieldDescriptor.numFields
        
        if (0 == numFields){
            return fieldObjList
        }
        if (numFields >= 1000) {
            //TODO: sometimes it may be a invalid value
             return fieldObjList
        }
        
        let fieldDescriptorOffset = searchProtocol.getOffsetFromVmAddress(UInt64(fieldDescriptorAddress))
        var fieldRecordAddr = Int(fieldDescriptorAddress) +  MemoryLayout<FieldDescriptor>.size
        var fieldRecordOff =  Int(fieldDescriptorOffset) +  MemoryLayout<FieldDescriptor>.size
        let fieldStart = UInt64(fieldDescriptorOffset) + UInt64(4 + 4 + 2 + 2 + 4)
    
         for i in 0..<Int(numFields) {
            ///  解析 属性
            
            let fieldAddr = UInt64(fieldStart) + UInt64( i * (4 * 3))
            let fieldNamePtr = data.readMove(Int(fieldAddr.add(8))).fix();
            
            let  fieldName = data.readCstring(at: fieldNamePtr)
            
            
             
            let record =   data.extract(FieldRecord.self, offset: fieldRecordOff)
             
            // 0x0 泛型属性 例如：let name: ClassA<String>? = nil
            if (record.flags != 0x2 && record.flags != 0x0){
                continue
            }
            
            var mangleNameAddr = UInt64(fieldRecordAddr) + UInt64(record.mangledTypeName) + 4
            correctAddress(&mangleNameAddr)
         
            
            let mangleNameOffset = searchProtocol.getOffsetFromVmAddress(UInt64(mangleNameAddr))
            
             
            fieldRecordAddr = fieldRecordAddr +  MemoryLayout<FieldRecord>.size
            fieldRecordOff  =  fieldRecordOff + MemoryLayout<FieldRecord>.size
            
            
            
            
            guard let firstStr =   data.readCString(from: Int(mangleNameOffset)) else{
                continue
            }
            
            var module = ""
            
            if firstStr.hasPrefix("0x01"){
                module = findMangleTypeName0x1(UInt64(mangleNameAddr))
                swiftRefsSet.insert(module)
            }else if firstStr.hasPrefix("0x02"){
                module = findMangleTypeName0x2(UInt64(mangleNameAddr))
                swiftRefsSet.insert(module)
            }else{
                module = getTypeFromMangledName(firstStr)
                 
            }
            
            let fieldObj =  SwiftTypeField(varName: fieldName, module: module)
            fieldObjList.append(fieldObj)
        }
        return fieldObjList
    }
    
    
    func calculateParentName(_ nominalPtr: UInt64, kind: SwiftContextDescriptorKind) -> String? {
        let parent:UInt32 = data.readU32(offset:  Int(nominalPtr + 4))
        var parentOffset = nominalPtr + 4 + UInt64(parent)
        let vm = section!.info.addr - UInt64(section!.info.offset)
        
        
        
        if parentOffset > vm { parentOffset = parentOffset - vm }
        
        while (kind != .Module) {
            let type:UInt32 = data.readU32(offset: Int(parentOffset))
            let flags = SwiftContextDescriptorFlags(type)
            let kind = flags.kind
            
            if kind == .Unknow {
                // 类似这样的代码（Type的Parent可能不属于Type）
                // func extensions(of value: Any) {
                //     struct Extensions : AnyExtensions {}
                //      return
                // }
                return nil
            }
            
            //Anonymous 匿名 二进制布局如下：Flag(4B)+Parent(4B)+泛型签名（不定长）+mangleName(4B)
            var genericPlaceholder:Int8 = 0
            if kind == .Anonymous {
                genericPlaceholder = addPlaceholderWithGeneric(nominalPtr)
            }
            
            //如果Anonymous 没有mangleName，则放弃
            if (kind == .Anonymous && !((type & 0xFFFF) == 0x01) ) {
                return nil
            }
            
            let offset = Int(parentOffset) + 2 * 4 + Int(genericPlaceholder)
            let parentNameContent: UInt32 = data.readU32(offset:offset)
            var parentNameOffset = Int(parentOffset) + 2 * 4 + Int(parentNameContent) + Int(genericPlaceholder)
            if (parentNameOffset > vm) {parentNameOffset = parentNameOffset - Int(vm)}
            let parentName = data.readCString(from:  parentNameOffset) ?? ""
            
            return parentName
        }
        return nil
    }
    
    
    func addPlaceholderWithGeneric(_ typeOffset:UInt64) -> Int8{
        let type = data.readU32(offset: Int(typeOffset))
        let flags = SwiftContextDescriptorFlags(type)
        
        // 除去通用
        if (!flags.isGeneric) {
            return 0
        }
        
        //非class | Anonymous不处理
        var front = 0
        
        //Anonymous的header为8字节
        var header = 8
        
        if flags.kind == .Class {
            //class的11个（4B） + addMetadataInstantiationCache （4B） + addMetadataInstantiationPattern（4B）
            front = (11 + 2) * 4
            //class的header为16字节
            header = 16
        }else if (flags.kind == .Anonymous){
            front = 2 * 4
        }else{
            return 0
        }
        
        
        let paramsCount = data.readI8(offset: Int(typeOffset) + front)
        let requeireCount = data.readI8(offset: Int(typeOffset) + front + 2)
        
        //4字节对齐
        let pandding:Int8 =  -paramsCount & 3
        
        return (Int8(header)  + paramsCount + pandding + 3 * 4 * (requeireCount));
    }
    
    
    
    
    /// 解析属性
    mutating func findMangleTypeName0x1(_ mangleNameAddr: UInt64) -> String {
        
        let mangleNameOffset = searchProtocol.getOffsetFromVmAddress(mangleNameAddr)
        
        let content =  DataTool.interception(with: data, from: mangleNameOffset.toInt + 1, length: 4).UInt32
        
        var contextAddr: UInt64 = mangleNameAddr + 1 + UInt64(content)
        /// 防止跨段
        correctAddress(&contextAddr)
        let contextOffset = searchProtocol.getOffsetFromVmAddress(contextAddr)
        
        let typeContext:SwiftBaseType = data.extract(SwiftBaseType.self, offset: contextOffset.toInt)
        
        
        var nameAddr =  UInt64(Int(contextAddr) + 2 * 4  +  Int(typeContext.name))
        /// 防止跨段
        correctAddress(&nameAddr)
        let nameOffset = searchProtocol.getOffsetFromVmAddress(UInt64(nameAddr))
        
        var mangleTypeName =  data.readCstring(at:nameOffset)
        
        
        
        var parentAddr = contextAddr + 1 * 4 + UInt64(typeContext.parent)
        /// 防止跨段
        correctAddress(&parentAddr)
        
        var parentOffset = searchProtocol.getOffsetFromVmAddress(parentAddr)
        
        /// 这里需要while循环是因为 如果有这样的    @objc public var hudStyle: ZLProgressHUD.HUDStyle = .lightBlur
        /// 嵌套几层的 则需要while将其遍历出来
        var kind:SwiftContextDescriptorKind = SwiftContextDescriptorKind.Unknow

        while kind != .Module && !invalidParent(parentOffset){
            let type:UInt32 = data.readU32(offset: Int(parentOffset))
            
            let flags = SwiftContextDescriptorFlags(type)
            
            kind = flags.kind
            
            if kind == .Unknow {
                break
            }
            
            var  genericPlaceholder: Int8 = 0;
            if (kind == .Anonymous) {
                genericPlaceholder =  addPlaceholderWithGeneric(parentOffset)
            }
            
            ///如果匿名的Anonymous 没有parentName，则放弃
            ///例如 private enum AutoScrollDirection  这种就是 没有 parentName
            if (kind == .Anonymous && !((type & 0xFFFF) == 0x01) ) {
                swiftRefsSet.insert(mangleTypeName)
                break
            }
            
            let offset = Int(parentOffset) + 2 * 4 + Int(genericPlaceholder)
            let parentNameContent: UInt32 = data.readU32(offset:offset)
            var parentNameOffset =  UInt64(parentOffset) + 2 * 4 + UInt64(parentNameContent) + UInt64(genericPlaceholder)
            if (parentNameOffset > vm) {parentNameOffset = parentNameOffset - vm}
            let parentName = data.readCstring(at: parentNameOffset)
            
            
            //例如匿名的 存储的事完整的名称 SwiftKindAnonymous
            if (kind == .Anonymous) {
                mangleTypeName = getTypeFromMangledName(parentName)
                break
            }
            
            mangleTypeName = parentName + "." + mangleTypeName
            
            let parentOffsetContent = DataTool.interception(with: data, from: Int(parentOffset) + 1 * 4, length: 4).UInt32
            
            parentAddr = parentAddr + 1 * 4 + UInt64(parentOffsetContent)
            /// 防止跨段
            correctAddress(&parentAddr)
            
            parentOffset = searchProtocol.getOffsetFromVmAddress(parentAddr)
        }
        return mangleTypeName
    }
    
    
    
    
    mutating func findMangleTypeName0x2(_ mangleNameAddr: UInt64) -> String {
        
        let mangleNameOffset = searchProtocol.getOffsetFromVmAddress(mangleNameAddr)
        
        let content =  DataTool.interception(with: data, from: mangleNameOffset.toInt + 1, length: 4).UInt32
        
        var indirectContextAddr = mangleNameAddr + 1 + UInt64(content)
        /// 防止跨段
        correctAddress(&indirectContextAddr)
        
        let indirectContextOffset = searchProtocol.getOffsetFromVmAddress(indirectContextAddr)
        var contextAddr =  DataTool.interception(with: data, from:indirectContextOffset.toInt , length: 8).UInt64
        if contextAddr == 0 {return ""}
        /// 防止跨段
        correctAddress(&contextAddr)
        
        let  contextOffset  = searchProtocol.getOffsetFromVmAddress(contextAddr)
        
        let typeContext:SwiftBaseType = data.extract(SwiftBaseType.self, offset: contextOffset.toInt)
        
        
        var nameAddr =  UInt64(Int(contextAddr) + 2 * 4  +  Int(typeContext.name))
        /// 防止跨段
        correctAddress(&nameAddr)
        let nameOffset = searchProtocol.getOffsetFromVmAddress(UInt64(nameAddr))
        
        var mangleTypeName =  data.readCstring(at:nameOffset)
        
        
        
        var parentAddr = contextAddr + 1 * 4 + UInt64(typeContext.parent)
        /// 防止跨段
        correctAddress(&parentAddr)
        
        var parentOffset = searchProtocol.getOffsetFromVmAddress(parentAddr)
        
        /// 这里需要while循环是因为 如果有这样的    @objc public var hudStyle: ZLProgressHUD.HUDStyle = .lightBlur
        /// 嵌套几层的 则需要while将其遍历出来
        var kind:SwiftContextDescriptorKind = SwiftContextDescriptorKind.Unknow

        while kind != .Module && !invalidParent(parentOffset){
            let type:UInt32 = data.readU32(offset: Int(parentOffset))
            
            let flags = SwiftContextDescriptorFlags(type)
            
            kind = flags.kind
            
            if kind == .Unknow {
                // 停止
                break
            }
            
            var  genericPlaceholder: Int8 = 0;
            if (kind == .Anonymous) {
                genericPlaceholder =  addPlaceholderWithGeneric(parentOffset)
            }
            
            ///如果匿名的Anonymous 没有parentName，则放弃
            ///例如 private enum AutoScrollDirection  这种就是 没有 parentName
            if (kind == .Anonymous && !((type & 0xFFFF) == 0x01) ) {
                swiftRefsSet.insert(mangleTypeName)
                break
            }
            
            let offset = Int(parentOffset) + 2 * 4 + Int(genericPlaceholder)
            let parentNameContent: UInt32 = data.readU32(offset:offset)
            var parentNameOffset =  UInt64(parentOffset) + 2 * 4 + UInt64(parentNameContent) + UInt64(genericPlaceholder)
            if (parentNameOffset > vm) {parentNameOffset = parentNameOffset - vm}
            let parentName = data.readCstring(at: parentNameOffset)
            
            
            
            //例如匿名的 存储的事完整的名称 SwiftKindAnonymous
            if (kind == .Anonymous) {
                mangleTypeName = getTypeFromMangledName(parentName)
                break
            }
            
            mangleTypeName = parentName + "." + mangleTypeName
            
            let parentOffsetContent = DataTool.interception(with: data, from: Int(parentOffset) + 1 * 4, length: 4).UInt32
            
            parentAddr = parentAddr + 1 * 4 + UInt64(parentOffsetContent)
            /// 防止跨段
            correctAddress(&parentAddr)
            
            parentOffset = searchProtocol.getOffsetFromVmAddress(parentAddr)
        }
        return mangleTypeName
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    // 出现跨段地址需要纠错，比如通过__TEXT端计算访问到__RODATA段，需要进行纠错
    func correctAddress(_ address:inout UInt64){
        address =  (address>(2*vm)) ? (address - UInt64(vm) ) : address
    }
    
    // 判断address 是否在对应的text当中
    func invalidParent(_ address:UInt64) -> Bool {
        guard let text = textConst else{
            return true
        }
        if (address >=  text.offset &&  address < UInt64(text.offset) + text.size ){
            return false
        }
        return true
    }
    
 

    
}






