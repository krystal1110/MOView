//
//  ClassListInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/30.
//

import Foundation


struct ClassInfo{
    var className: String?
    var supclassName: String?
    var class64Info: Class64Info
    var class64: Class64
    var relativeDataOffset: Int
    var pointerValue: Swift.UInt64
    var explanationItems: [ExplanationItem] = []
    
    init(_ relativeDataOffset: Int, pointerValue: UInt64, class64: Class64, class64Info:Class64Info , className:String? = nil , supclassName:String? = nil ){
        self.relativeDataOffset = relativeDataOffset
        self.pointerValue = pointerValue
        self.class64 = class64
        self.class64Info = class64Info
        self.className = className
        self.supclassName = supclassName
        
        explanationItems.append(ExplanationItem(sourceDataRange: nil, model: ExplanationModel(description: "Offset", explanation:"\(relativeDataOffset)")))
 
        explanationItems.append(ExplanationItem(sourceDataRange: nil, model: ExplanationModel(description: "Data", explanation:pointerValue.hex)))
        
        if let name = className {
            explanationItems.append(ExplanationItem(sourceDataRange: nil, model: ExplanationModel(description: "Class Name", explanation:name)))
        }
    }
}




struct Class64 {
    let isa: UInt64
    let superClass: UInt64
    let cache: UInt64
    let vtable: UInt64
    let data: UInt64
}

/*
 在c当中的结构体
 unsigned int flags; 是4个字节 - 对应的Swift中是 Int32
 unsigned long long; 是8个字节 - 对应的Swift中是 Int64也就是Int
 **/
struct Class64Info
{
    let flags: Int32 //objc-runtime-new.h line:379~460
    let instanceStart: Int32
    let instanceSize: Int32
    let reserved: Int32
    let instanceVarLayout: UInt64
    let name: UInt64
    let baseMethods: UInt64
    let baseProtocols: UInt64
    let instanceVariables: UInt64
    let weakInstanceVariables: UInt64
    let baseProperties: UInt64
};





struct ClassListInterpreter: Interpreter {
    
    var dataSlice: Data
    
    var section: Section64?
    
    var searchProtocol: SearchProtocol
    
    let pointerLength: Int = 8
    
    var classRefSet: Set<String> = []
    
    var classNameSet: Set<String> = []
    
    init(with  dataSlice: Data, section:Section64,  searchProtocol:SearchProtocol){
        self.dataSlice = dataSlice
        self.section = section
        self.searchProtocol = searchProtocol
    }
    
    
    mutating func transitionData() -> [ClassInfo]  {
        let rawData = self.dataSlice
        
        guard rawData.count % pointerLength == 0 else { fatalError() /* section of type S_LITERAL_POINTERS should be in align of 8 (bytes) */  }
        
        var classInfoList: [ClassInfo] = []
        
        let numberOfPointers = rawData.count / 8
        
        for index in 0..<numberOfPointers {
            let relativeDataOffset = index * pointerLength
            if  let classInfo = loadClassList(relativeDataOffset){
                classInfoList.append(classInfo)
            }
        }
         return classInfoList
    }
    
    
    func translationItem(with pointer:ReferencesPointer) -> ExplanationItem {
        
#warning("TODO")
        var symbolName =  ""
        //        var symbolName = self.searchProtocol.searchString(by: pointer.pointerValue)
        
        //        if (symbolName == nil){
        //            symbolName = self.searchProtocol.searchStringInSymbolTable(by: pointer.pointerValue)
        //        }
        
        return ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: dataSlice, start: pointer.relativeDataOffset, self.pointerLength),
                               model: ExplanationModel(description: "Pointer Value (Virtual Address)",
                                                       explanation: pointer.pointerValue.hex,
                                                       
                                                       extraDescription: "Referenced String Symbol",
                                                       extraExplanation: symbolName))
    }
    
    
    
    mutating func loadClassList(_ relativeDataOffset:Int) -> ClassInfo?{
        
        var supclassNameStr: String?
        var classNameStr: String?
        
        let data =  dataSlice.select(from: relativeDataOffset, length: pointerLength)
        
        let machoData = searchProtocol.getMachoData()
        
        let classOffset =  searchProtocol.getOffsetFromVmAddress(data.UInt64)
        
        if classOffset > 0 &&  classOffset < searchProtocol.getMachoData().count {
            
            let targetClass =  machoData.extract(Class64.self, offset: classOffset.toInt)
            
            var targetClassInfoOffset =  searchProtocol.getOffsetFromVmAddress(targetClass.data)
            
            // Remove the decimal
            targetClassInfoOffset = (targetClassInfoOffset / 8) * 8
            
            let targetClassInfo =  machoData.extract(Class64Info.self, offset: targetClassInfoOffset.toInt)
            
            let classNameOffset =  searchProtocol.getOffsetFromVmAddress(targetClassInfo.name)
            
      
            
            // load super class
            if targetClass.superClass != 0 {
                let data = searchProtocol.getOffsetFromVmAddress(targetClass.superClass)
                let superClass = machoData.extract(Class64.self, offset: data.toInt)
                var superClassOffset =  searchProtocol.getOffsetFromVmAddress(superClass.data)
                superClassOffset = (superClassOffset / 8) * 8;
                
                
                let superClassInfo =  machoData.extract(Class64Info.self, offset: superClassOffset.toInt)
                let superClassNameOffset = searchProtocol.getOffsetFromVmAddress(superClassInfo.name)
                if let superClassName = machoData.readCStringName(from: superClassNameOffset.toInt) {
                    classRefSet.insert(superClassName)
                }
            }
            
            
            if let className =  machoData.readCString(from: classNameOffset.toInt){
                if className.contains("_Tt"){
                    classNameStr = getTypeFromMangledName(className)
                    classNameSet.insert(classNameStr!)
                }else if className.hasPrefix("PodsDummy_"){
                    
                }
                else{
                    classNameStr = className
                    classNameSet.insert(classNameStr!)
                }
            }
            
            //enumerate member variables 枚举成员变量
            let varListOffset = searchProtocol.getOffsetFromVmAddress(targetClassInfo.instanceVariables)
            if (varListOffset > 0 && varListOffset < searchProtocol.getMax()){
        
                let offset = varListOffset + 4
                let data =  machoData.select(from: offset.toInt , length: 4)
                let varCount = data.Int32
                for i in 0..<varCount{
                    let offset =  varListOffset.toInt + MemoryLayout<Ivar64_list_t>.size + Int(i) * MemoryLayout<Ivar64_t>.size
                    let varInfo:Ivar64_t =   machoData.extract(Ivar64_t.self, offset: offset)
                    var methodNameOffset = varInfo.type
                    methodNameOffset = Int64(searchProtocol.getOffsetFromVmAddress(UInt64(methodNameOffset)))
                    
                    if (methodNameOffset > 0 && methodNameOffset < searchProtocol.getMax()){
                        if var typeName = searchProtocol.getMachoData().readCStringName(from: Int(methodNameOffset)){
                            
                           typeName = typeName.replacingOccurrences(of: "@\"", with: "")
                           typeName = typeName.replacingOccurrences(of:"\"", with: "")
                            supclassNameStr = typeName
                           classRefSet.insert(typeName)
                        }
                    }
                }
            }
            
            return ClassInfo(relativeDataOffset, pointerValue: data.UInt64,class64: targetClass, class64Info: targetClassInfo, className: classNameStr, supclassName: supclassNameStr)
        }else{
            return nil
//            return ClassInfo(relativeDataOffset, pointerValue: data.UInt64,class64: nil, class64Info: nil, className: classNameStr, supclassName: supclassNameStr)
        }
    }
    
 
}



struct Ivar64_list_t
{
    let entsize: Int32
    let count: Int32
};

struct Ivar64_t
{
    let offset: Int64
    let name: Int64
    let type: Int64
    let alignment: Int32
    let size: Int32
};
