//
//  TranslationRead.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/8.
//

import Foundation


class TranslationRead {
    
    let machoDataSlice: DataSlice
    private(set) var translated: Int = 0
    private(set) var items: [ExplanationItem] = []
    
    init(machoDataSlice: DataSlice) {
        self.machoDataSlice = machoDataSlice
    }
    
    // 读取macho文件信息
    func translate<T>(next straddle: Straddle, dataInterpreter: (Data) -> T, itemContentGenerator: (T) -> ExplanationModel) -> T {
       
        defer { translated += straddle.raw }
        
        let rawData = self.machoDataSlice.interception(from: translated, length: straddle.raw).raw
        
        let rawDataAbsoluteRange = machoDataSlice.startOffset+translated..<machoDataSlice.startOffset+translated+straddle.raw
        
        let interpreted: T = dataInterpreter(rawData)
        
//        items.append(TranslationItem(sourceDataRange: rawDataAbsoluteRange, content: itemContentGenerator(interpreted)))
        
        return interpreted
    }
 
    
    func skip(_ straddle: Straddle) -> Self {
        translated = translated + straddle.raw
        return self
    }
    
    func append(_ itemModel: ExplanationModel, forRange range: Range<Int>) {
        let item = ExplanationItem(sourceDataRange: range, model: itemModel)
        items.append(item)
    }
 
    
}

struct JYDataTranslationRead{
    static func UInt32(_ data: Data) -> Swift.UInt32 {
        return data.UInt32
    }
}



enum Straddle {
    case word
    case doubleWords
    case quadWords
    case rawNumber(Int)
    
    var raw: Int {
        switch self {
        case .word:
            return 2
        case .doubleWords:
            return 4
        case .quadWords:
            return 8
        case .rawNumber(let rawValue):
            return rawValue
        }
    }
}

struct DataShifter {
    
    private let data: Data
    private(set) var shifted: Int = .zero
    var shiftable: Bool { data.count > shifted }
    
    init(_ data: Data) {
        self.data = data
    }
    
    mutating func shift(_ straddle: Straddle, updateIndex: Bool = true) -> Data {
        let num = straddle.raw
        guard num > 0 else { fatalError() }
        guard shifted + num <= data.count else { fatalError() }
        defer { if (updateIndex) { shifted += num } }
        return data.select(from: shifted, length: num)
    }
    
    mutating func skip(_ straddle: Straddle) {
        shifted += straddle.raw
    }
}
