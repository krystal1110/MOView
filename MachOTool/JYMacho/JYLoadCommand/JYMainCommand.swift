//
//  JYMainCommand.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/15.
//

import Foundation


/*
 struct entry_point_command {
     uint32_t  cmd;    /* LC_MAIN only used in MH_EXECUTE filetypes */
     uint32_t  cmdsize;    /* 24 */
     uint64_t  entryoff;    /* file (__TEXT) offset of main() */
     uint64_t  stacksize;/* if not zero, initial stack size */
 };
 **/

class JYMainCommand: JYLoadCommand {
    
    let entryOffset: UInt64
    let stackSize: UInt64
    
    required init(with dataSlice: JYDataSlice, commandType: LoadCommandType, translationStore: JYTranslationRead? = nil) {
        
        
        let translationStore = JYTranslationRead(machoDataSlice: dataSlice).skip(.quadWords)
        
        self.entryOffset = translationStore.translate(next: .quadWords, dataInterpreter: {$0.UInt64}, itemContentGenerator: { value in
            ExplanationModel(description: "Entry Offset (relative to __TEXT)", explanation: value.hex)
        })
        
        self.stackSize = translationStore.translate(next: .quadWords, dataInterpreter: {$0.UInt64}, itemContentGenerator: { value in
            ExplanationModel(description: "Stack Size", explanation: value.hex)
        })
        
        super.init(with: dataSlice, commandType: commandType, translationStore: translationStore)
        
    }
}
