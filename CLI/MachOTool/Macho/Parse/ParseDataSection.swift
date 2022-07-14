//
//  ParseDataSection.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/27.
//

import Foundation


class ParseDataSection {
    
    var componts: [ComponentInfo] = []
    
    func parseDataSection(_ data:Data ,commonds: [MachOLoadCommandType], searchProtocol: SearchProtocol ){
        
        for item in commonds {
            if item.name == SegmentType.DATA.rawValue {
                let model =  item as! MachOLoadCommand.Segment
                
                let _ =  model.sections.compactMap{parseDataSectionItem(data,section:$0,searchProtocol: searchProtocol)}
                print("🔥🔥🔥 解析 __DATA 完成  🔥🔥🔥")
            }
        }
    }
    
    
    
    private  func parseDataSectionItem(_ data: Data, section:Section64 , searchProtocol: SearchProtocol)  {
        
        let sectionTypeRawValue = section.info.flags & 0x000000FF
        
        guard let sectionType = SectionType(rawValue: sectionTypeRawValue) else {
            print("Unknown section type with raw value: \(sectionTypeRawValue). Contact the author.")
            fatalError()
        }
        
        let dataSlice = DataTool.interception(with: data, from: Int(section.info.offset), length: Int(section.info.size))
        
        
        if (section.sectname == DataSection.objc_protolist.rawValue  ){
            
            let interpreter = ReferencesInterpreter(with: dataSlice, section: section, searchProtocol: searchProtocol)
            let ptrList = interpreter.transitionData()
            let compont = ReferencesCmponent(dataSlice, section: section, referencesPtrList: ptrList)
            componts.append(compont)
        }
        else if  (section.sectname == DataSection.objc_classlist.rawValue){
            // __DATA_objc_classlist  objc_classrefs  objc_supperrefs 存储类的相关信息
            var interpreter = ClassListInterpreter(with: dataSlice, section: section, searchProtocol: searchProtocol)
            let classInfoList = interpreter.transitionData()
            let compont = ClassListCmponent(dataSlice, section: section, classInfoList: classInfoList, classRefSet: interpreter.classRefSet,classNameSet: interpreter.classNameSet)
            componts.append(compont)
        }
        
        else if  (section.sectname == DataSection.objc_classlist.rawValue || section.sectname == DataSection.objc_classrefs.rawValue || section.sectname == DataSection.objc_superrefs.rawValue  || section.sectname == DataSection.objc_nlclslist.rawValue ){
            // __DATA_objc_classlist  objc_classrefs  objc_supperrefs 存储类的相关信息
            var interpreter = ClassListInterpreter(with: dataSlice, section: section, searchProtocol: searchProtocol)
            let classInfoList = interpreter.transitionData()
            let compont = ClassListCmponent(dataSlice, section: section, classInfoList: classInfoList)
            componts.append(compont)
        }
        
        else if  (section.sectname == DataSection.objc_catlist.rawValue  || section.sectname == DataSection.objc_nlcatlist.rawValue  ){
            //  __DATA_objc_catlist  __DATA_objc_nlcatlist  存储使用到 category的类
            let interpreter = CategoryInterpreter(with: dataSlice, section: section, searchProtocol: searchProtocol)
            let classInfoList = interpreter.transitionData()
            let compont = ClassListCmponent(dataSlice, section: section, classInfoList: classInfoList)
            componts.append(compont)
        }
        
        
        else if (section.sectname == DataSection.la_symbol_ptr.rawValue || section.sectname == DataSection.got.rawValue){
            /*
             __DATA,__got ->  Non-Lazy Symbol Pointers
             __DATA,__la_symbol_ptr -> Lazy Symbol Pointers
             解析非懒加载和懒加载符号表
             **/
            
            let interpreter = LazySymbolInterpreter(with: dataSlice, section: section, searchProtocol: searchProtocol)
            let list = interpreter.transitionData()
            let compont = LazySymbolComponent(dataSlice, section: section, lazySymbolTableList: list)
            componts.append(compont)
        }
        
        else if (section.sectname == DataSection.objc_selrefs.rawValue){
            let interpreter = ReferencesInterpreter(with: dataSlice, section: section, searchProtocol: searchProtocol)
            let stringTableList = interpreter.transitionData()
            let compont = ReferencesCmponent(dataSlice, section: section, referencesPtrList: stringTableList)
            componts.append(compont)
            
        }else if (section.sectname == DataSection.cfstring.rawValue){
            // 存储 Objective C 字符串的元数据
            let interpreter = CFStringInterpreter(with: dataSlice, section: section, searchProtocol: searchProtocol)
            let objcCFStringList = interpreter.transitionData()
            let compont = CFStringComponent(dataSlice, section: section, objcCFStringList: objcCFStringList)
            componts.append(compont)
            
        }else {
            let compont = UnknownCmponent(dataSlice, section:section )
            componts.append(compont)
            
        }
        
        
        
    }
}

