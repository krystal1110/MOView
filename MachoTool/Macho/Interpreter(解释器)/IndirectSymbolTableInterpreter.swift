//
//  IndirectSymbolTableInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/23.
//

import Foundation

class IndirectSymbolTableInterpreter {
    let data: DataSlice
    let is64Bit: Bool
    let machoProtocol: MachoProtocol
    
    init(with data: DataSlice, is64Bit: Bool, machoProtocol:MachoProtocol) {
        self.data = data
        self.is64Bit = is64Bit
        self.machoProtocol = machoProtocol
    }
    
    
    func indirectSymbolTableInterpreter(from dynamicSymbolCommand: DynamicSymbolTableCompont) -> IndirectSymbolTableInterpreterInfo?  {
        let indirectSymbolTableStartOffset = Int(dynamicSymbolCommand.indirectsymoff)
        let indirectSymbolTableSize = Int(dynamicSymbolCommand.nindirectsyms * 4)
        if indirectSymbolTableSize == .zero { return nil }
        let indirectSymbolTableData = data.interception(from: indirectSymbolTableStartOffset, length: indirectSymbolTableSize)
       
        let interpreter =  MachoModel<IndirectSymbolTableEntryModel>.init().generateVessel(data: indirectSymbolTableData, is64Bit: is64Bit)
        
 
        let model:IndirectSymbolTableEntryModel = interpreter[1]
        let symbolEntryModel  = self.machoProtocol.indexInSymbolTable(at: model.symbolTableIndex)
        let symbolName  = self.machoProtocol.stringInStringTable(at: Int(symbolEntryModel?.indexInStringTable ?? 0))
        
        
        print("🔥🔥🔥🔥🔥🔥 symbolNmae = \(symbolName)")
        
        return IndirectSymbolTableInterpreterInfo(with: indirectSymbolTableData,
                                              is64Bit: is64Bit,
                                              interpreter: interpreter,
                                              title: "Indirect Symbol Table",
                                              subTitle: "__LINKEDIT")
    }
    
       
    
    
    
    
}
