//
//  JYSymbolTableCommand.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/15.
//

import Foundation


extension MachOLoadCommand {
    public struct LC_SymbolTable: MachOLoadCommandType {
        
        public var name: String
        public var command: symtab_command? = nil;
        
        init(command: symtab_command) {
            let types =   LoadCommandType(rawValue: command.cmd)
            self.name = types?.name ?? " Unknow Command Name "
            self.command = command
        }
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(symtab_command.self, offset: loadCommand.offset)
            self.init(command: command)
        }
    }
}



//class JYSymbolTableCommand: JYLoadCommand {
//    let symbolTableOffset: UInt32
//    let numberOfSymbolTable: UInt32
//    let stringTableOffset: UInt32
//    let stringTableSize: UInt32
//
//    required init(with dataSlice: Data, commandType: LoadCommandType, translationStore: TranslationRead? = nil) {
//        let translationStore = TranslationRead(machoDataSlice: dataSlice).skip(.quadWords)
//
//        symbolTableOffset = translationStore.translate(next: .doubleWords, dataInterpreter: { $0.UInt32 }, itemContentGenerator: { value in
//            ExplanationModel(description: "Symbol table offset", explanation: value.hex)
//        })
//
//        numberOfSymbolTable = translationStore.translate(next: .doubleWords, dataInterpreter: { $0.UInt32 }, itemContentGenerator: { value in
//            ExplanationModel(description: "Number of entries", explanation: "\(value)")
//        })
//
//        stringTableOffset = translationStore.translate(next: .doubleWords, dataInterpreter: { $0.UInt32 }, itemContentGenerator: { value in
//            ExplanationModel(description: "String table offset", explanation: value.hex)
//        })
//
//        stringTableSize = translationStore.translate(next: .doubleWords, dataInterpreter: { $0.UInt32 }, itemContentGenerator: { value in
//            ExplanationModel(description: "Size of string table", explanation: value.hex)
//        })
//
//        super.init(with: dataSlice, commandType: commandType, translationStore: translationStore)
//    }
//}
