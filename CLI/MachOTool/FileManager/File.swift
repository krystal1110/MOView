//
//  JYFile.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/8.
//

import Foundation

// 架构种类
public enum MagicType {
    case ar
    case fat // 胖二进制
    case macho32
    case macho64

    public init?(_ fileData: Data) {
        if fileData.starts(with: [0x21, 0x3C, 0x61, 0x72, 0x63, 0x68, 0x3E, 0x0A]) {
            // "!<arch>\n"
            self = .ar
        } else if fileData.starts(with: [0xCA, 0xFE, 0xBA, 0xBE]) {
            // 0xcafebabe is also Java class files' magic number.
            self = .fat
        } else if fileData.starts(with: [0xCE, 0xFA, 0xED, 0xFE]) {
            self = .macho32
        } else if fileData.starts(with: [0xCF, 0xFA, 0xED, 0xFE]) {
            self = .macho64
        } else {
            return nil
        }
    }

    // 对应的架构类型
    var name: String {
        switch self {
        case .ar:
            return ""
        case .fat:
            return "Fat Binarys File Magic"
        case .macho32:
            return "MachO(32bit) File Magic"
        case .macho64:
            return "MachO(64bit) File Magic"
        }
    }

    // 判断是否为macho文件
    var isMachoFile: Bool {
        return self == .macho32 || self == .macho64
    }
}

public struct File {
    let fileName: String
    let fileSize: Int
   public let machos: [Macho]

   public init(fileURL: URL) throws {
        let fileName = fileURL.lastPathComponent
        guard let fileData = try? Data(contentsOf: fileURL) else { fatalError("file error") }
        self.init(with: fileName, fileData: fileData)
    }

    init(with fileName: String, fileData: Data) {
        self.fileName = fileName

        fileSize = fileData.count
        guard let magicType = MagicType(fileData) else { fatalError() }
        switch magicType {
        case .macho32, .macho64:
            machos = [Macho(machoDataRaw: fileData, machoFileName: fileName)]
        case .ar:
            #warning("TODO")
            machos = [Macho(machoDataRaw: fileData, machoFileName: fileName)]
        case .fat:
            #warning("TODO")
            machos = [Macho(machoDataRaw: fileData, machoFileName: fileName)]
        }
    }
    
   
    
}
