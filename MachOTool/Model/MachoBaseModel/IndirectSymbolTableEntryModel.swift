//
//  IndirectSymbolTableModel.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/23.
//

import Foundation


struct IndirectSymbolTableEntryModel:MachoExplainModel{
    static func modelSize(is64Bit: Bool) -> Int {
        4
    }
    
    static func numberOfExplanationItem() -> Int {
        1
    }
    
    let entryRange: Range<Int>
    let symbolTableIndex: Int
//    let machoSearchSource: MachoSearchSource
    
    init(with data: DataSlice, is64Bit: Bool) {
        self.entryRange = data.absoluteRange(.zero, 4)
        self.symbolTableIndex = Int(data.raw.UInt32)
//        self.machoSearchSource = machoSearchSource
    }
    
    func translationItem() -> ExplanationItem {
        var symbolName: String?
//        var symbolTableInterpreter:SymbolTableInterpretInfo = SymbolTableInterpretInfo()
//        var stringInterpreter:StringInterpreter = StringInterpreter()
//        let symbolTableEntryModel =  symbolTableInterpreter.symbolTableList[self.symbolTableIndex]
//        symbolName = stringInterpreter.findString(at:Int(symbolTableEntryModel.indexInStringTable))
        return ExplanationItem(sourceDataRange: entryRange,
                                       model: ExplanationModel(description: "Symbol Table Index",
                                                                       explanation: "\(symbolTableIndex)",
                                                                       extraDescription: "Referrenced Symbol",
                                                                       extraExplanation: symbolName))
    }
    
}
