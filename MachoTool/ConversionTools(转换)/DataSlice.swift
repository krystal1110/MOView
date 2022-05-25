//
//  DataSlice.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/8.
//

import Foundation

struct DataSlice {
    private let machoData: Data
    let startOffset: Int // 初始偏移量
    let count: Int

    // 计算地址范围
    var raw: Data {
        return machoData[(machoData.startIndex + startOffset) ..< (machoData.startIndex + startOffset + count)]
    }

    init(_ machoData: Data) {
        self.init(machoData: machoData, startOffset: .zero, length: machoData.count)
    }

    private init(machoData: Data, startOffset: Int, length: Int) {
        guard let magicType = MagicType(machoData), magicType.isMachoFile else { fatalError() }
        self.machoData = machoData
        self.startOffset = startOffset
        count = length
    }

    func interception(from: Int, length: Int? = nil) -> DataSlice {
        if let length = length {
            // 截取的是 from + length
            if length == .zero { print("error") }

            // 如果截取超过了 本身长度 则fatalError
            guard from + length <= count else { fatalError() }
            return DataSlice(machoData: machoData, startOffset: startOffset + from, length: length)
        } else {
            guard from < count else { fatalError() }
            // 截取的是 from ~ 文件末尾的地址
            return DataSlice(machoData: machoData, startOffset: startOffset + from, length: count - from)
        }
    }
}

extension DataSlice {
    func absoluteRange(_ start: Int, _ length: Int) -> Range<Int> {
        return startOffset + start ..< startOffset + start + length
    }

    func absoluteRange(_ relativeRange: Range<Int>) -> Range<Int> {
        return startOffset + relativeRange.lowerBound ..< startOffset + relativeRange.upperBound
    }
}
