//
//  ParseTextSection.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/25.
//

import Foundation


class ParseTextSection {
    
    var textInstructionPtr: UnsafeMutablePointer<cs_insn>?
    
    var componts: [ComponentInfo] = []
    
    func parseTextSection(_ data:Data ,commonds: [MachOLoadCommandType], searchProtocol: SearchProtocol ){
        
        for item in commonds {
            if item.name == SegmentType.TEXT.rawValue {
                
                
                let model =  item as! MachOLoadCommand.Segment
                
                let _ =  model.sections.compactMap{parseTextSectionItem(data,section:$0,searchProtocol: searchProtocol)}
                 
            }
        }
        print("🔥🔥🔥 解析 __TEXT 完成  🔥🔥🔥")
    }
    
    
    
    private  func parseTextSectionItem(_ data: Data, section:Section64 , searchProtocol: SearchProtocol)  {
        
        print(section.sectname + "," + section.segname )
        
        let sectionTypeRawValue = section.info.flags & 0x000000FF
        
        guard let sectionType = SectionType(rawValue: sectionTypeRawValue) else {
            print("Unknown section type with raw value: \(sectionTypeRawValue). Contact the author.")
            fatalError()
        }
        
        let dataSlice = DataTool.interception(with: data, from: Int(section.info.offset), length: Int(section.info.size))
        
        
        /*
         __TEXT,__cstring    __TEXT,__objc_classname   __TEXT,__objc_methtype 均会来到此处
         因为都是存储的都为字符串类型
         **/
        if (section.sectname == TextSection.cstring.rawValue ||  section.sectname == TextSection.objc_classname.rawValue || section.sectname == TextSection.objc_methtype.rawValue){
            let interpreter = StringInterpreter(with: dataSlice, section: section, searchProtocol: searchProtocol)
            let stringTableList = interpreter.transitionData()
            let compont = StringComponent(dataSlice, section: section, stringList: stringTableList)
            componts.append(compont)
        }
        
        
        
        else if (section.sectname == TextSection.ustring.rawValue){
            /*
             __TEXT, __cstring
             **/
            let interpreter  = UstringInterpreter(with: dataSlice, section: section, searchProtocol: searchProtocol)
            let uStringList  =  interpreter.transitionData()
            let compont = UStringComponent(dataSlice, section: section, uStringList: uStringList)
            componts.append(compont)
            
        }else if (section.sectname == TextSection.text.rawValue){
            // parse __Text  转为汇编
            
            let textInstructionPtr = CapStoneHelper.instructions(data, from: UInt64(section.info.offset), length: UInt64(section.info.size))
            self.textInstructionPtr = textInstructionPtr
            let compont = TextComponent(dataSlice, section: section, textInstructionPtr: textInstructionPtr)
            componts.append(compont)
            
        }else if (section.sectname == TextSection.swift5types.rawValue){
            /*
             __swift5_types 中存储的是 Class 、Struct 、 Enum 的地址
             types 不是 8 字节地址，而是 4 字节，并且所存储的数据明显不是直接地址
             当前文件偏移 + 随后4字节中存储的 value 即可得到 class 地址
             **/
            
            let interpreter  = SwiftTypesInterpreter(with: data, dataSlice: dataSlice, section: section, searchProtocol: searchProtocol)
            let swiftTypesList  =  interpreter.transitionData()
            let compont = SwiftTypesCmponent(dataSlice, section: section, swiftTypesList: swiftTypesList)
            componts.append(compont)
            
        }else if (section.sectname == TextSection.swift5reflstr.rawValue){
            
            let interpreter = StringInterpreter(with: dataSlice, section: section, searchProtocol: searchProtocol)
            let stringTableList = interpreter.transitionData()
            let compont = StringComponent(dataSlice, section: section, stringList: stringTableList)
            componts.append(compont)
        } else {
            
            let compont = UnknownCmponent(dataSlice, section:section )
            componts.append(compont)
            
        }
        
    }
    
    
}

