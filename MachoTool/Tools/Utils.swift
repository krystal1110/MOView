//
//  JYUtils.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/8.
//

import Foundation

extension Data {
    private func cast<T>(to type: T.Type) -> T {
        guard count == MemoryLayout<T>.size else { fatalError() }
        return withUnsafeBytes { $0.bindMemory(to: type).baseAddress!.pointee }
    }

    var UInt8: Swift.UInt8 { if count == 1 { return first! } else { fatalError() } }
    var UInt16: Swift.UInt16 { cast(to: Swift.UInt16.self) }
    var UInt32: Swift.UInt32 { cast(to: Swift.UInt32.self) }
    var UInt64: Swift.UInt64 { cast(to: Swift.UInt64.self) }

    var Int32: Swift.Int32 { cast(to: Swift.Int32.self)}
    
    func select(from: Data.Index, length: Data.Index) -> Self {
        return self[startIndex + from ..< startIndex + from + length]
    }

    var utf8String: String? {
        return String(data: self, encoding: .utf8)
    }
    
    var asciiString: String? {
        return String(data: self, encoding: .ascii)
    }
    
    func readCString(from: Int) -> String? {
        if (from >= self.count) {
            return nil;
        }
        var address: Int = (from);
        var result:[UInt8] = [];
        while true {
            let val: UInt8 = self[address];
            if (val == 0) {
                break;
            }
            address += 1;
            result.append(val);
        }
        
        if let str = String(bytes: result, encoding: String.Encoding.ascii) {
            if (str.isAsciiStr()) {
                return str;
            }
        }
        
        if (result.count > 10000) {
            return nil
        }
        
        let tmp = result.reduce("0x") { (result, val:UInt8) -> String in
            return result + String(format: "%02x", val);
        }
        return tmp;
    }
    
    
 
}

extension String {
    var spaceRemoved: String {
        return trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\0", with: "")
    }
    
    func isAsciiStr() -> Bool {
        return self.range(of: ".*[^A-Za-z0-9_$ ].*", options: .regularExpression) == nil;
    }
}

extension Int {
    var hex: String { String(format: "0x%0X", self) }
    var isNotZero: Bool { self != .zero }
    func bitAnd(_ v: Self) -> Bool { self & v != 0 }
    
    func add(_ offset: Int64) -> UInt64 {
        var address: UInt64 = 0
        if offset < 0 {
            address = UInt64(self)  - UInt64(abs(offset) );
        }else{
            address = UInt64(self)  + UInt64(offset);
        }
        return address
    }
    
    func fix() -> Int {
        return   self & 0xFFFFFFFF
    }
}

extension UInt16 {
    var hex: String { String(format: "0x%0X", self) }
    var isNotZero: Bool { self != .zero }
    func bitAnd(_ v: Self) -> Bool { self & v != 0 }
}

extension UInt32 {
    var hex: String { String(format: "0x%0X", self) }
    var isNotZero: Bool { self != .zero }
    func bitAnd(_ v: Self) -> Bool { self & v != 0 }
}

extension UInt64 {
    var hex: String { String(format: "0x%llX", self) }
    var isNotZero: Bool { self != .zero }
    func bitAnd(_ v: Self) -> Bool { self & v != 0 }
   
    func add(_ offset: Int) -> UInt64 {
        var address: UInt64 = 0
        if offset < 0 {
            address = self  - UInt64(abs(offset) );
        }else{
            address = self  + UInt64(offset);
        }
        return address
    }
    
    var toInt:Int{ Int(self)}
    
    func fix() -> UInt64 {
        return  UInt64(self & 0xFFFFFFFF)
    }
    
}

class Utils {
    static func makeRange(start: Int, length: Int) -> Range<Int> {
        return start ..< start + length
    }

    static func range(after range: Range<Int>, distance: Int = 0, length: Int) -> Range<Int> {
        guard length != 0 else { fatalError() }
        return range.upperBound + distance ..< range.upperBound + distance + length
    }
    
    static func readCharToString<T>(_ ptr: inout T) -> String {
          let str = withUnsafePointer(to: ptr) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: ptr)) {
                String(cString: $0)
            }
          }
        return str
    }
    
    
    
    
    static func strStr(_ haystack: String, _ needle: String) -> Bool {
        if  Utils.sunday(text: Array(haystack), pattern: Array(needle)) == -1 {
            return false
        }else{
            return true
        }
    }
    
    private static func sunday(text: [Character], pattern: [Character]) -> Int {
        let m = text.count, n = pattern.count
        guard m >= n else { return -1 }
        guard n > 0 else { return -1 }
        
        let shift = pattern.enumerated().reduce(into: [Character: Int]()) { (result, arg1) in
            result[arg1.element] = n - arg1.offset
        }
        var i = 0
        while i <= m - n {
            var j = 0
            while j < n && pattern[j] == text[i + j] { j += 1 }
            if j >= n { return i }
            if i + n >= m { break }
            i += shift[text[i + n], default: n + 1]
        }
        
        return -1
    }
    
}

extension String {
    
    /// 是否为空字符串
    var isBlank: Bool {
        let trimmedStr = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedStr.isEmpty
    }
    
    public func removingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }
    
    public func removingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }
    
    func toPointer() -> UnsafePointer<UInt8>? {
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        let stream = OutputStream(toBuffer: buffer, capacity: data.count)
        
        stream.open()
        data.withUnsafeBytes { (bp:UnsafeRawBufferPointer) in
            if let sp:UnsafePointer<UInt8> = bp.baseAddress?.bindMemory(to: UInt8.self, capacity: MemoryLayout<Any>.stride) {
                stream.write(sp, maxLength: data.count)
            }
        }
        
        stream.close()
        
        return UnsafePointer<UInt8>(buffer)
    }
 
}
 

 
extension Data {
 
    func readI32(offset: Int) -> Int32 {
        return readValue(offset) ?? 0
    }
    
    func readU32(offset: Int) -> UInt32 {
        return readValue(offset) ?? 0
    }
    
    func readU64(offset: Int) -> UInt64 {
        return readValue(offset) ?? 0
    }
    
    
    
    func readValue<Type>(_ offset: Int) -> Type? {
        let val:Type? = self.withUnsafeBytes { (ptr:UnsafeRawBufferPointer) -> Type? in
            return ptr.baseAddress?.advanced(by: offset).load(as: Type.self);
        }
        return val;
    }
    
    
    func readMove(_ offset: Int) -> UInt64 {
        let val = readU32(offset: offset)
        return offset.add(Int64(val))
    }
    
    
    func extract<T>(_ type: T.Type, offset: Int = 0) -> T {
        let data = self[offset..<offset + MemoryLayout<T>.size];
        let ret = data.withUnsafeBytes { (ptr:UnsafeRawBufferPointer) -> T in
            return ptr.load(as: T.self)
        }
        return ret;
    }
    
    
   
}
