//
//  DyldInfoCommand.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/6.
//

import Foundation


class DyldInfoCommand : JYLoadCommand {
    let rebaseOffset: UInt32
    let rebaseSize: UInt32
    
    let bindOffset: UInt32
    let bindSize: UInt32
    
    let weakBindOffset: UInt32
    let weakBindSize: UInt32
    
    let lazyBindOffset: UInt32
    let lazyBindSize: UInt32
    
    let exportOffset: UInt32
    let exportSize: UInt32
    
    
    required init(with data: Data, commandType: LoadCommandType, translationStore: TranslationRead? = nil) {
        let translationStore = TranslationRead(machoDataSlice: data).skip(.quadWords)
        
        self.rebaseOffset =
        translationStore.translate(next: .doubleWords,
                                 dataInterpreter: DataInterpreterPreset.UInt32,
                                 itemContentGenerator: { value in ExplanationModel(description: "Rebase Info File Offset", explanation: value.hex) })
        
        self.rebaseSize =
        translationStore.translate(next: .doubleWords,
                                 dataInterpreter: DataInterpreterPreset.UInt32,
                                 itemContentGenerator: { value in ExplanationModel(description: "Rebase Info Size", explanation: value.hex) })
        
        self.bindOffset =
        translationStore.translate(next: .doubleWords,
                                 dataInterpreter: DataInterpreterPreset.UInt32,
                                 itemContentGenerator: { value in ExplanationModel(description: "Binding Info File Offset", explanation: value.hex) })
        
        self.bindSize =
        translationStore.translate(next: .doubleWords,
                                 dataInterpreter: DataInterpreterPreset.UInt32,
                                 itemContentGenerator: { value in ExplanationModel(description: "Binding Info Size", explanation: value.hex) })
        
        self.weakBindOffset =
        translationStore.translate(next: .doubleWords,
                                 dataInterpreter: DataInterpreterPreset.UInt32,
                                 itemContentGenerator: { value in ExplanationModel(description: "Weak Binding Info File Offset", explanation: value.hex) })
        
        self.weakBindSize =
        translationStore.translate(next: .doubleWords,
                                 dataInterpreter: DataInterpreterPreset.UInt32,
                                 itemContentGenerator: { value in ExplanationModel(description: "Weak Binding Info Size", explanation: value.hex) })
        
        self.lazyBindOffset =
        translationStore.translate(next: .doubleWords,
                                 dataInterpreter: DataInterpreterPreset.UInt32,
                                 itemContentGenerator: { value in ExplanationModel(description: "Lazy Binding Info File Offset", explanation: value.hex) })
        
        self.lazyBindSize =
        translationStore.translate(next: .doubleWords,
                                 dataInterpreter: DataInterpreterPreset.UInt32,
                                 itemContentGenerator: { value in ExplanationModel(description: "Lazy Binding Info Size", explanation: value.hex) })
        
        self.exportOffset =
        translationStore.translate(next: .doubleWords,
                                 dataInterpreter: DataInterpreterPreset.UInt32,
                                 itemContentGenerator: { value in ExplanationModel(description: "Export Info File Offset", explanation: value.hex) })
        
        self.exportSize =
        translationStore.translate(next: .doubleWords,
                                 dataInterpreter: DataInterpreterPreset.UInt32,
                                 itemContentGenerator: { value in ExplanationModel(description: "Export Info Size", explanation: value.hex) })
        
        super.init(with: data, commandType: commandType, translationStore: translationStore)
    }
    
 
}
