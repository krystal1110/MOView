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



class SwiftTypesInterpreter :BaseInterpreter{
    
    let machoData:Data
    
    init(with data: Data,
         is64Bit: Bool,
         machoProtocol: MachoProtocol,
         sectionVirtualAddress: UInt64,
         machoData: Data) {
        
        self.machoData = machoData
        super.init(data, is64Bit: is64Bit, machoProtocol: machoProtocol, sectionVirtualAddress: sectionVirtualAddress)
    }
    
    func loadData(_ fileOffset:Int64) {
        
          var nominalList:[SwiftNominalModel] = [];
        
        let numberOfTypes = data.count / 4
        for i in 0..<numberOfTypes {
            let localOffset =  i * 4
            
            let tmpPtr = UInt64(fileOffset) + UInt64(localOffset)
            let nominalLocalOffset:Int32 =  self.machoData.readI32(offset: Int(tmpPtr))  //-22140
            
             //地址偏移
            let nominalArchOffset:Int64 = Int64(fileOffset) + Int64(localOffset) + Int64(nominalLocalOffset);
            
            let nominalPtr:UInt64 =  UInt64(nominalArchOffset)
            
            let flags:UInt32 = machoData.readU32(offset: Int(nominalPtr))
            
//            parentVal    Int32    16777228
//            let parentVal:Int32 = machoData.readI32(offset: nominalPtr.add(4).toInt)   // 可能是模块名
            
//            namePtr    UInt64    4295111164 通过fix为 143868
            let namePtr = machoData.readMove(nominalPtr.add(8).toInt).fix()
            
            guard let nameStr: String = machoData.readCString(from: Int(namePtr))else{
                return
            }
           
            //accessorPtr对应的是 metaData 访问函数将始终返回正确的元数据记录;
            let accessorPtr = machoData.readMove(nominalPtr.add(12).toInt).fix()
        
            
            let obj: SwiftNominalModel = SwiftNominalModel()
            obj.typeName = nameStr
            obj.contextDescriptorFlag = SwiftContextDescriptorFlags(flags)
            obj.nominalOffset = nominalArchOffset
            obj.accessorOffset = UInt64((accessorPtr))
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
            let fieldDescriptorPtr:UInt64 = machoData.readMove(nominalPtr.add(4 * 4).toInt).fix();
            dumpFieldDescriptor(fieldDescriptorPtr, to: obj)
            
            let mangledTypeNamePtr = machoData.readMove(Int(fieldDescriptorPtr)).fix();
            if let mangledTypeName = machoData.readCString(from: mangledTypeNamePtr.toInt) {
                //Log("    mangledTypeName \(mangledTypeName) \(mangledTypeNamePtr.desc)")
                obj.mangledTypeName = mangledTypeName;
            }
            print("🔥🔥🔥 类名为 \(obj.typeName)   \n   我的父类为 \(obj.superClassName) \n 我拥有\(obj.fields.count)属性")
        }
    }
    
    
    
    /*
         解析 superClass
     **/
    private func resolveSuperClassName(_ nominalPtr: UInt64) -> String {
        //nominalPtr
        let ptr = nominalPtr.add(4 * 5)
        let superClassTypeVal = self.machoData.readI32(offset: Int(ptr));
        if (superClassTypeVal == 0) {
            return "";
        }
        var retName: String = "";
        let superClassRefPtr = ptr.add(Int(superClassTypeVal));
        if let superRefStr = self.machoData.readCString(from:Int(superClassRefPtr)), !superRefStr.isEmpty {
            retName = superRefStr; // resolve later
        }
        return retName;
    }
    
    private func dumpFieldDescriptor(_ fieldDescriptorPtr: UInt64, to: SwiftNominalModel ){
        
        let numFields = machoData.readU32(offset: fieldDescriptorPtr.add(4 + 4 + 2 + 2).toInt)
        if (0 == numFields){
            return
        }
        if (numFields >= 1000) {
            //TODO: sometimes it may be a invalid value
            fatalError("[dumpFieldDescriptor] \(numFields) too many fields of \(to.typeName), ignore format")
        }
        
        let fieldStart:UInt64 = fieldDescriptorPtr.add(4 + 4 + 2 + 2 + 4)
        for i in 0..<Int(numFields) {
            let fieldAddress = fieldStart.add(i * (4 * 3))
            
            
            /*
             获取是什么类型 例如 Int a ，这里获取的 type 就是 Int(Type得到的是 Si 需要转换成 Int)
             **/
            let typeNamePtr = machoData.readMove(fieldAddress.add(4).toInt).fix()
            let typeName = machoData.readCString(from: typeNamePtr.toInt)
            
            if let type = typeName, (type.count <= 0 || type.count > 100) {
                print("---")
                continue
            }
            
            /*
             获取属性名称 例如 Int a ，这里获取的 fieldName 就是 a
             **/
            let fieldNamePtr = machoData.readMove(fieldAddress.add(8).toInt).fix();
            let fieldName = machoData.readCString(from: fieldNamePtr.toInt);
            
            if let field = fieldName, (field.count <= 0 || field.count > 100) {
                continue
            }
           
            // 存储
            if let type = typeName, let field = fieldName {
            
                // 通过Swift Runtime 恢复真实名字
                let realType = getTypeFromMangledName(type)
                let fieldObj = SwiftNominalObjField()
                fieldObj.name = field
                fieldObj.type = realType
                fieldObj.namePtr = fieldNamePtr
                fieldObj.typePtr = typeNamePtr
                to.fields.append(fieldObj)
            }
        }
    }
    
}


 


 
