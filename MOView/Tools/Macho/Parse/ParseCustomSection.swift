//
//  ParseCustomSection.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/27.
//

import Foundation


class ParseCustomSection {
    
    var modules: [MachoModule] = []
    
    func parseCustomSections(_ data:Data ,commonds: [MachOLoadCommandType], searchProtocol: SearchProtocol ){
        
        for item in commonds {
            
            
            let type  = type(of: item)
            
            if (type == MachOLoadCommand.Segment.self){
                
                let commond = item as! MachOLoadCommand.Segment
                
                if (commond.name != SegmentType.DATA.rawValue && commond.name != SegmentType.TEXT.rawValue  && commond.name != SegmentType.LINKEDIT.rawValue  && commond.name != SegmentType.PAGEZERO.rawValue){
                    
                    parseCustomSectionItem(data, sections:commond.sections, searchProtocol: searchProtocol)
                }
            }
        }
        print("🔥🔥🔥 解析 自定义 section64 完成  🔥🔥🔥")
    }
    
    
    
    private  func parseCustomSectionItem(_ data: Data, sections:[Section64] , searchProtocol: SearchProtocol)  {
        
        for i in sections {
            let dataSlice = DataTool.interception(with: data, from: Int(i.info.offset), length: Int(i.info.size))
            let module = UnknownModule(with: dataSlice, section: i)
            modules.append(module)
        }
    }
}


