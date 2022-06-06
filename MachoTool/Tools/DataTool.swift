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
    
    
}
