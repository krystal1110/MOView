//
//  TextComponent.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/27.
//

import Foundation

struct TextComponent: ComponentInfo{
    var dataSlice: Data
    var componentTitle: String?
    var componentSubTitle: String?
    var section: Section64?
    var textInstructionPtr: UnsafeMutablePointer<cs_insn>?
    
    init(_ dataSlice: Data, section: Section64?, textInstructionPtr:  UnsafeMutablePointer<cs_insn>? ) {
        self.dataSlice = dataSlice
        self.componentTitle = section?.segname
        self.componentSubTitle = section?.sectname
        self.section = section
        self.textInstructionPtr = textInstructionPtr
    }
    
}
