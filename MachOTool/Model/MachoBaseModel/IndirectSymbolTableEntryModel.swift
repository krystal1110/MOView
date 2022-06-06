//
//  IndirectSymbolTableModel.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/23.
//

import Foundation

struct IndirectSymbolTableEntryModel: MachoExplainModel {
 
    
    
    static func modelSize() -> Int {
        return 4
    }
 
    let entryRange: Range<Int>
    let symbolTableIndex: Int
    var explanationItem: ExplanationItem?

    init(with data: Data, is64Bit: Bool) {
        entryRange = DataTool.absoluteRange(with: data, start: .zero, 4)
        symbolTableIndex = Int(data.UInt32)
    }

    func translationItem(machoProtocol: MachoProtocol) -> ExplanationItem? {
        var symbolName: String?
        let symbolEntryModel = machoProtocol.indexInSymbolTable(at: symbolTableIndex)
        guard let symbolEntryModel = symbolEntryModel?.indexInStringTable else {
            return ExplanationItem(sourceDataRange: entryRange,
                                   model: ExplanationModel(description: "Symbol Table Index",
                                                           explanation: "\(symbolTableIndex)",
                                                           extraDescription: "Referrenced Symbol",
                                                           extraExplanation: "🔥🔥🔥 Unknown Symbol"))
        }
        symbolName = machoProtocol.stringInStringTable(at: Int(symbolEntryModel))
        return ExplanationItem(sourceDataRange: entryRange,
                               model: ExplanationModel(description: "Symbol Table Index",
                                                       explanation: "\(symbolTableIndex)",
                                                       extraDescription: "Referrenced Symbol",
                                                       extraExplanation: symbolName))
    }
}
