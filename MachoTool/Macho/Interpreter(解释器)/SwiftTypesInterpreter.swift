//
//  SwiftTypesInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/13.
//

import Foundation




struct SwiftType {
    let flag: UInt32
    let parent: UInt32
}

struct SwiftMethod {
    let kind: UInt32
    let offset : UInt32
}


//没有Vtable 的话使用此结构体会错误
struct SwiftClassType {
    let flag: UInt32
    let parent: UInt32
    let name : Int32
    let accessFunction:Int32
    let fieldDescriptor: Int32
    let superclassType: Int32
    let metadataNegativeSizeInWords: UInt32
    let metadataPositiveSizeInWords: UInt32
    let numImmediateMembers: UInt32
    let numFields: UInt32
    let unknow1: UInt32
    let offset: UInt32
    let numMethods: UInt32
};

// 这是类重写的函数
//OverrideTable结构如下，紧随VTable后4字节为OverrideTable数量，再其后为此结构数组
struct SwiftOverrideMethod {
    let overrideClass:SwiftClassType
    let overrideMethod:SwiftMethod
    let method:SwiftMethod
};





struct SwiftTypesInterpreter: Interpreter {
    
    var dataSlice: Data
    
    var section: Section64?
    
    var searchProtocol: SearchProtocol
    
    let pointerLength: Int = 8
    
    let data: Data
    
    init(with data:Data , dataSlice: Data, section:Section64,  searchProtocol:SearchProtocol){
        self.data = data
        self.dataSlice = dataSlice
        self.section = section
        self.searchProtocol = searchProtocol
    }
    
    
    // 转换为 stroeInfo 存储信息
    func transitionData()  -> [SwiftNominalModel] {
        
        let fileOffset = Int64(section!.fileOffset)
        
        var nominalList:[SwiftNominalModel] = [];
        
        let numberOfTypes = dataSlice.count / 4
        for i in 0..<numberOfTypes {
            
            
            
            
            
            
            let localOffset =  i * 4
            let tmpPtr = UInt64(fileOffset) + UInt64(localOffset)
            let nominalLocalOffset:Int32 =  self.data.readI32(offset: Int(tmpPtr))  //  -22328
            
            //地址偏移
            let nominalArchOffset:Int64 = Int64(fileOffset) + Int64(localOffset) + Int64(nominalLocalOffset);
            
            let nominalPtr:UInt64 =  UInt64(nominalArchOffset)
            
            let flags:UInt32 = data.readU32(offset: Int(nominalPtr))
            
            
            
            
            
            let namePtr = data.readMove(nominalPtr.add(8).toInt).fix()
            let nameStr: String = data.readCString(from: Int(namePtr)) ?? ""
            
            //accessorPtr对应的是 metaData 访问函数将始终返回正确的元数据记录;
            let accessorPtr = data.readMove(nominalPtr.add(12).toInt).fix()
            
            
            var obj: SwiftNominalModel = SwiftNominalModel()
            obj.typeName = nameStr
            obj.contextDescriptorFlag = SwiftContextDescriptorFlags(flags)
            obj.nominalOffset = nominalArchOffset
            obj.accessorOffset = UInt64((accessorPtr))
            
            obj.parentName =  calculateParentName(nominalPtr, kind: obj.contextDescriptorFlag.kind)
            
            nominalList.append(obj);
            
            if obj.contextDescriptorFlag.kind == .Class {
                // 类
                obj.superClassName = resolveSuperClassName(nominalPtr)
            }else if obj.contextDescriptorFlag.kind == .Enum {
                // 枚举
            }else if obj.contextDescriptorFlag.kind == .Struct {
                // 结构体
            }
            // 拿到 fieldDescriptor
            let fieldDescriptorPtr:UInt64 = data.readMove(nominalPtr.add(4 * 4).toInt).fix();
            dumpFieldDescriptor(fieldDescriptorPtr, to: &obj)
            
            let mangledTypeNamePtr = data.readMove(Int(fieldDescriptorPtr)).fix();
            if let mangledTypeName = data.readCString(from: mangledTypeNamePtr.toInt) {
                //Log("    mangledTypeName \(mangledTypeName) \(mangledTypeNamePtr.desc)")
                obj.mangledTypeName = mangledTypeName;
            }
            
            
            
            print("类名为 \(obj.typeName)   \n我的父类为 \(obj.superClassName) \n我拥有\(obj.fields.count)属性")
        }
        
        return nominalList
    }
    
    
    
    /*
     解析 superClass
     **/
    private func resolveSuperClassName(_ nominalPtr: UInt64) -> String {
        //nominalPtr
        let ptr = nominalPtr.add(4 * 5)
        let superClassTypeVal = self.data.readI32(offset: Int(ptr));
        if (superClassTypeVal == 0) {
            return "";
        }
        var retName: String = "";
        let superClassRefPtr = ptr.add(Int(superClassTypeVal));
        if let superRefStr = self.data.readCString(from:Int(superClassRefPtr)), !superRefStr.isEmpty {
            retName = superRefStr; // resolve later
        }
        
        return retName;
    }
    
    private func dumpFieldDescriptor(_ fieldDescriptorPtr: UInt64, to:inout SwiftNominalModel ){
        
        
        let numFields = data.readU32(offset: fieldDescriptorPtr.add(4 + 4 + 2 + 2).toInt)
        
        if (0 == numFields){
            return
        }
        if (numFields >= 1000) {
            //TODO: sometimes it may be a invalid value
            return
//            fatalError("[dumpFieldDescriptor] \(numFields) too many fields of \(to.typeName), ignore format")
        }
        
        let fieldStart:UInt64 = fieldDescriptorPtr.add(4 + 4 + 2 + 2 + 4)
        for i in 0..<Int(numFields) {
            let fieldAddress = fieldStart.add(i * (4 * 3))
            
            
            /*
             获取是什么类型 例如 Int a ，这里获取的 type 就是 Int(Type得到的是 Si 需要转换成 Int)
             **/
            let typeNamePtr = data.readMove(fieldAddress.add(4).toInt).fix()
            
            let typeName = data.readCString(from: typeNamePtr.toInt)
            
            if let type = typeName, (type.count <= 0 || type.count > 100) {
                continue
            }
            
            /*
             获取属性名称 例如 Int a ，这里获取的 fieldName 就是 a
             **/
            let fieldNamePtr = data.readMove(fieldAddress.add(8).toInt).fix();
            let fieldName = data.readCString(from: fieldNamePtr.toInt);
            
            if let field = fieldName, (field.count <= 0 || field.count > 100) {
                continue
            }
            
            // 存储
            if let type = typeName, let field = fieldName {
                
                // 通过Swift Runtime 恢复真实名字
                let realType = getTypeFromMangledName(type)
                var fieldObj = SwiftNominalObjField()
                fieldObj.name = field
                fieldObj.type = realType
                fieldObj.namePtr = fieldNamePtr
                fieldObj.typePtr = typeNamePtr
                to.fields.append(fieldObj)
            }
        }
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
            
//             let  isGenericType = flags.isGeneric
            
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
    
  
    
 
    
     
    
}






