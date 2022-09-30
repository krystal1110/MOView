//
//  TextComponent.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/27.
//

import Foundation
 
  class TextModule:MachoModule{
      var csInsnPointer: UnsafeMutablePointer<cs_insn>
      var section: Section64
    
    init(with dataSlice: Data,
         section:Section64,
         csInsnPointer:UnsafeMutablePointer<cs_insn>) {
        self.section = section
        self.csInsnPointer = csInsnPointer
        super.init(with: dataSlice, translateItems: [])
        self.moduleTitle = "Section"
        self.moduleSubTitle = "\(section.segname),\(section.sectname)"
    }
    
      override func lazyConvertExplanation(at section: Int) {
        
        let offset = Int(self.section.info.offset) + (section * 4)
        var explanationItems: [ExplanationItem] = []
        var op_str   = self.csInsnPointer[Int(section)].op_str
        var mnemonic   = self.csInsnPointer[Int(section)].mnemonic
        let dataStr = Utils.readCharToString(&op_str)
        let asmStr = Utils.readCharToString(&mnemonic)
        explanationItems.append(ExplanationItem(sourceDataRange: nil, model: ExplanationModel(description: "Offset", explanation: offset.hex)))
        explanationItems.append(ExplanationItem(sourceDataRange: nil, model: ExplanationModel(description: "Asm", explanation: asmStr)))
        if !asmStr.contains("ret"){
            explanationItems.append(ExplanationItem(sourceDataRange: nil, model: ExplanationModel(description: "Instruction", explanation: dataStr)))
        }
 
        self.translateItems.append(explanationItems)
    }
    
      override func numberOfExplanationItems(at section: Int) -> Int {
        guard section < self.translateItems.count else {return 0}
        return self.translateItems[section].count
    }
    
      override func numberOfExplanationItemsSections() -> Int {
        return  Int(self.section.info.size/4)
    }
    
}

