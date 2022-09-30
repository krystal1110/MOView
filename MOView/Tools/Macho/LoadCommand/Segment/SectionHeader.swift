//
//  SectionHeader.swift
//  MOView
//
//  Created by ljy on 2022/9/29.
//

import Foundation


struct SectionHeader {
    
    let segment: String
    let section: String
    let addr: UInt64
    let size: UInt64
    let offset: UInt32
    let align: UInt32
    let sectionType: SectionType
    let translate: Translate
   
    let data: Data

    init(data: Data) {
         
        self.data = data
        
        let translate = Translate(dataSlice: data)
        
        self.section = translate.translate(from: 0, length: 16, dataInterpreter: {$0.utf8String!.spaceRemoved}) { value in
            ExplanationModel(description: "Section Name", explanation: value)}
        
        
        self.segment = translate.translate(from: 16, length: 16, dataInterpreter: {$0.utf8String?.spaceRemoved ?? ""}) { value  in
            ExplanationModel(description: "Segment Name", explanation: value)}
        
        
        self.addr = translate.translate(from: 32, length: 8, dataInterpreter: {$0.UInt64}) { value  in
            ExplanationModel(description: "Virtual Address", explanation: value.hex)}
        
  
        self.size = translate.translate(from: 40, length: 8, dataInterpreter: {$0.UInt64}) { value  in
            ExplanationModel(description: "Section Size", explanation: value.hex)}
        
        self.offset = translate.translate(from: 48, length: 4, dataInterpreter: {$0.UInt32}) { value  in
            ExplanationModel(description: "File Offset", explanation: value.hex)}
        
        self.align = translate.translate(from: 52, length: 4, dataInterpreter: {$0.UInt32}) { value  in
            ExplanationModel(description: "Align", explanation: value.hex)}
 
        let flags = DataTool.interception(with: data, from: 64 , length: 4).UInt32
        let range = DataTool.absoluteRange(with: data, start: 64, 4)
        
        let sectionTypeRawValue = flags & 0x000000ff
        guard let sectionType = SectionType(rawValue: sectionTypeRawValue) else {
            print("Unknown section type with raw value: \(sectionTypeRawValue). Contact the author.")
            fatalError()
        }
        self.sectionType = sectionType
        
        let model = ExplanationModel(description: "Section Type", explanation: "\(sectionType)")
        let item = ExplanationItem(sourceDataRange: range, model: model)
        translate.insert(item: item)
        
        self.translate = translate
    }
    
 
}

 
enum SectionAttribute {
    case S_ATTR_PURE_INSTRUCTIONS
    case S_ATTR_NO_TOC
    case S_ATTR_STRIP_STATIC_SYMS
    case S_ATTR_NO_DEAD_STRIP
    case S_ATTR_LIVE_SUPPORT
    case S_ATTR_SELF_MODIFYING_CODE
    case S_ATTR_DEBUG
    case S_ATTR_SOME_INSTRUCTIONS
    case S_ATTR_EXT_RELOC
    case S_ATTR_LOC_RELOC
    
    var name: String {
        switch self {
        case .S_ATTR_PURE_INSTRUCTIONS:
            return "S_ATTR_PURE_INSTRUCTIONS"
        case .S_ATTR_NO_TOC:
            return "S_ATTR_NO_TOC"
        case .S_ATTR_STRIP_STATIC_SYMS:
            return "S_ATTR_STRIP_STATIC_SYMS"
        case .S_ATTR_NO_DEAD_STRIP:
            return "S_ATTR_NO_DEAD_STRIP"
        case .S_ATTR_LIVE_SUPPORT:
            return "S_ATTR_LIVE_SUPPORT"
        case .S_ATTR_SELF_MODIFYING_CODE:
            return "S_ATTR_SELF_MODIFYING_CODE"
        case .S_ATTR_DEBUG:
            return "S_ATTR_DEBUG"
        case .S_ATTR_SOME_INSTRUCTIONS:
            return "S_ATTR_SOME_INSTRUCTIONS"
        case .S_ATTR_EXT_RELOC:
            return "S_ATTR_EXT_RELOC"
        case .S_ATTR_LOC_RELOC:
            return "S_ATTR_LOC_RELOC"
        }
    }
}

struct SectionAttributes {
    
    let raw: UInt32
    let attributes: [SectionAttribute]
    
    var descriptions: [String] {
        if attributes.isEmpty {
            return ["NONE"]
        } else {
            return attributes.map({ $0.name })
        }
    }
    
    init(raw: UInt32) {
        self.raw = raw
        var attributes: [SectionAttribute] = []
        if raw.bitAnd(0x80000000) { attributes.append(.S_ATTR_PURE_INSTRUCTIONS) }
        if raw.bitAnd(0x40000000) { attributes.append(.S_ATTR_NO_TOC) }
        if raw.bitAnd(0x20000000) { attributes.append(.S_ATTR_STRIP_STATIC_SYMS) }
        if raw.bitAnd(0x10000000) { attributes.append(.S_ATTR_NO_DEAD_STRIP) }
        if raw.bitAnd(0x08000000) { attributes.append(.S_ATTR_LIVE_SUPPORT) }
        if raw.bitAnd(0x04000000) { attributes.append(.S_ATTR_SELF_MODIFYING_CODE) }
        if raw.bitAnd(0x02000000) { attributes.append(.S_ATTR_DEBUG) }
        if raw.bitAnd(0x00000400) { attributes.append(.S_ATTR_SOME_INSTRUCTIONS) }
        if raw.bitAnd(0x00000200) { attributes.append(.S_ATTR_EXT_RELOC) }
        if raw.bitAnd(0x00000100) { attributes.append(.S_ATTR_LOC_RELOC) }
        self.attributes = attributes
    }
    
    func hasAttribute(_ attri: SectionAttribute) -> Bool {
        return self.attributes.contains(attri)
    }
}
