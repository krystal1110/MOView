//
//  DataTool.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/5.
//

import Foundation


  class DataTool{
    
    // 截取Data
      class func interception(with data: Data, from: Int, length: Int? = nil) -> Data {
        if let length = length {
            // 截取的是 from + length
            if length == .zero { print("error") }
            
            // 如果截取超过了 本身长度 则fatalError
            guard from + length <= data.count else { fatalError() }
            return data[(data.startIndex + from) ..< (data.startIndex + from + length)]
        } else {
            guard from < data.count else { fatalError() }
            // 截取的是 from ~ 文件末尾的地址
            return data[(data.startIndex + from) ..< (data.startIndex + data.count - from)]
        }
    }
    
    
      class func absoluteRange(with data: Data, start: Int, _ length: Int) -> Range<Int> {
        return data.startIndex + start ..< data.startIndex + start + length
    }
    
       class func absoluteRange(with data: Data, relativeRange: Range<Int>) -> Range<Int> {
        return data.startIndex  + relativeRange.lowerBound ..< data.startIndex  + relativeRange.upperBound
    }
    
      class func bytes(_ data: Data , at offset: Int, length: Int) -> [UInt8] {
        return [UInt8](DataTool.interception(with: data, from: offset, length: length))
    }
    
      class func bytesToString(_ bytes:[UInt8] ) -> String{
        var tmpString = (bytes.map { String(format: "%02X", $0) }).joined(separator: "")
//        let paddingLength = (HexLineStore.NumberOfBytesPerLine - bytes.count) * 2
        let paddingLength = 16;
        tmpString.append(contentsOf: [Character](repeating: " ", count: paddingLength))
        return tmpString
    }
    
  
    
    
}


class PointerTool{
    class func add(_ address:UInt64, offset: Int64) -> UInt64 {
        var address: UInt64 = 0
        if (offset < 0) {
            address = address - UInt64(abs(offset) )
        } else {
            address = address + UInt64(offset)
        }
        return address
    }
}

