//
//  JYSymbolTableCommand.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/15.
//

import Foundation


class JYSymbolTableCommand:JYLoadCommand{
    
    let symbolTableOffset: UInt32
    let numberOfSymbolTableEntries: UInt32
    let stringTableOffset: UInt32
    let sizeOfStringTable: UInt32
    
    
    required init(with dataSlice: JYDataSlice, commandType: LoadCommandType, translationStore: JYTranslationRead? = nil) {
        
        let translationStore = JYTranslationRead(machoDataSlice: dataSlice).skip(.quadWords)
        
        self.symbolTableOffset = translationStore.translate(next: .doubleWords, dataInterpreter: {$0.UInt32}, itemContentGenerator: { value in
            ExplanationModel(description: "Symbol table offset", explanation: value.hex)
        })
        
        self.numberOfSymbolTableEntries = translationStore.translate(next: .doubleWords, dataInterpreter: {$0.UInt32}, itemContentGenerator: { value in
            ExplanationModel(description: "Number of entries", explanation: "\(value)")
        })
     
        self.stringTableOffset = translationStore.translate(next: .doubleWords, dataInterpreter: {$0.UInt32}, itemContentGenerator: { value in
            ExplanationModel(description: "String table offset", explanation:  value.hex )
        })
        
        self.sizeOfStringTable = translationStore.translate(next: .doubleWords, dataInterpreter: {$0.UInt32}, itemContentGenerator: { value in
            ExplanationModel(description: "Size of string table", explanation: value.hex)
        })
        
        super.init(with: dataSlice, commandType: commandType, translationStore: translationStore)
    }
    
}
