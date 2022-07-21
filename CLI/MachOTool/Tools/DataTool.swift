//
//  DataTool.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/5.
//

import Foundation


public class DataTool{
    
    // 截取Data
   public class func interception(with data: Data, from: Int, length: Int? = nil) -> Data {
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
    
    
 public class func absoluteRange(with data: Data, start: Int, _ length: Int) -> Range<Int> {
        return data.startIndex + start ..< data.startIndex + start + length
    }

    public  class func absoluteRange(with data: Data, relativeRange: Range<Int>) -> Range<Int> {
        return data.startIndex  + relativeRange.lowerBound ..< data.startIndex  + relativeRange.upperBound
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
 
