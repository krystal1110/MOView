//
//  IndirectSymbolTableInterpreter.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/23.
//

import Foundation

class IndirectSymbolTableInterpreter {
    let data: Data
    let is64Bit: Bool
    let machoProtocol: MachoProtocol

    init(with data: Data, is64Bit: Bool, machoProtocol: MachoProtocol) {
        self.data = data
        self.is64Bit = is64Bit
        self.machoProtocol = machoProtocol
    }

    func indirectSymbolTableInterpreter(from dynamicSymbolCommand: DynamicSymbolTableCompont) -> IndirectSymbolTableStoreInfo? {
        let indirectSymbolTableStartOffset = Int(dynamicSymbolCommand.indirectsymoff)
        let indirectSymbolTableSize = Int(dynamicSymbolCommand.nindirectsyms * 4)
        if indirectSymbolTableSize == .zero { return nil }
        let indirectSymbolTableData = DataTool.interception(with: data, from: indirectSymbolTableStartOffset, length: indirectSymbolTableSize)

        let interpreter = MachoModel<IndirectSymbolTableEntryModel>.init().generateVessel(data: indirectSymbolTableData, is64Bit: is64Bit)

        let indirectSymbolTableList = translation(array: interpreter)

        return IndirectSymbolTableStoreInfo(with: indirectSymbolTableData,
                                                  is64Bit: is64Bit,
                                                  title: "Indirect Symbol Table",
                                                  subTitle: "__LINKEDIT",
                                                  indirectSymbolTableList: indirectSymbolTableList)
    }

    func translation(array: [IndirectSymbolTableEntryModel]) -> [IndirectSymbolTableEntryModel] {
        var indirectSymbolTableList: [IndirectSymbolTableEntryModel] = []

        for index in 0 ..< array.count {
            var model = array[index]
//           var explanationItem = model.translationItem( machoProtocol: self.machoProtocol)
            model.explanationItem = model.translationItem(machoProtocol: machoProtocol)
            indirectSymbolTableList.append(model)
        }
        return indirectSymbolTableList
    }
}
