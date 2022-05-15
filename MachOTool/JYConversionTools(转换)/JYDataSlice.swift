//
//  JYDataSlice.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/8.
//

import Foundation

struct JYDataSlice{
    
    private let machoData: Data
    let startOffset: Int // 初始偏移量
    let count: Int
     
    // 计算地址范围
    var raw:Data{
        return machoData[(machoData.startIndex + startOffset)..<(machoData.startIndex + startOffset + count)]
    }
    
    
    
    init(_ machoData: Data) {
        self.init(machoData:machoData, startOffset: .zero, length: machoData.count)
    }
    
    private init( machoData: Data, startOffset: Int, length: Int) {
        guard let magicType = MagicType(machoData), magicType.isMachoFile else { fatalError() }
        self.machoData = machoData
        self.startOffset = startOffset
        self.count = length
    }
    
    
    func interception(from:Int, length:Int? = nil)-> JYDataSlice {
        if let length = length {
            // 截取的是 from + length
            if length == .zero{ print("error")}
            
            // 如果截取超过了 本身长度 则fatalError
            guard from + length <= self.count else {fatalError()}
            return JYDataSlice(machoData: machoData, startOffset: startOffset + from , length: length)
        }else{
            guard from < self.count else {fatalError()}
            // 截取的是 from ~ 文件末尾的地址
            return JYDataSlice(machoData: machoData, startOffset: startOffset + from, length: self.count - from)
        }
    }
    
   
    
    
}

extension JYDataSlice {
    func absoluteRange(_ start: Int, _ length: Int) -> Range<Int> {
        return startOffset+start..<startOffset+start+length
    }
    
    func absoluteRange(_ relativeRange: Range<Int>) -> Range<Int> {
        return startOffset+relativeRange.lowerBound..<startOffset+relativeRange.upperBound
    }
}
