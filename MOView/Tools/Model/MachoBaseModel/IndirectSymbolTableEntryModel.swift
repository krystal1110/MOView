//
//  IndirectSymbolTableModel.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/23.
//

import Foundation

struct IndirectSymbolTableEntryModel {
    
    let entryRange: Range<Int>
    let symbolTableIndex: Int
    var explanationItem: ExplanationItem?
    
    init(with data: Data) {
        entryRange = DataTool.absoluteRange(with: data, start: .zero, 4)
        symbolTableIndex = Int(data.UInt32)
    }
 
 
    
    func findSymbolName(searchProtocol: SearchProtocol) -> ExplanationItem? {
 
        let symbolName =  searchProtocol.searchStringInSymbolTableIndex(at: symbolTableIndex)
 
        return ExplanationItem(sourceDataRange: entryRange,
                               model: ExplanationModel(description: "Symbol Table Index",
                                                       explanation: "\(symbolTableIndex)",
                                                       extraDescription: "Referrenced Symbol",
                                                       extraExplanation: symbolName))
    }
    
    
}
