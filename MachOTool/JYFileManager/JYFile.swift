//
//  JYFile.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/8.
//

import Foundation

// 架构种类
enum MagicType{
    case ar
    case fat // 胖二进制
    case macho32
    case macho64
    
    init?(_ fileData: Data) {
        if fileData.starts(with: [0x21, 0x3C, 0x61, 0x72, 0x63, 0x68, 0x3E, 0x0A]) {
            // "!<arch>\n"
            self = .ar
        } else if fileData.starts(with: [0xca, 0xfe, 0xba, 0xbe]) {
            // 0xcafebabe is also Java class files' magic number.
            self = .fat
        } else if fileData.starts(with: [0xce, 0xfa, 0xed, 0xfe]) {
            self = .macho32
        } else if fileData.starts(with: [0xcf, 0xfa, 0xed, 0xfe]) {
            self = .macho64
        } else {
            return nil
        }
    }
    
    // 对应的架构类型
    var readable:String {
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
    var isMachoFile:Bool {
        return self == .macho32 || self == .macho64
    }
    
    
}



struct File {
    
    let fileName:String
    let fileSize: Int
    let machos:[JYMacho]
    
    init(fileURL:URL) {
        let fileName = fileURL.lastPathComponent
        guard let fileData = try? Data(contentsOf: fileURL) else { fatalError()}
        self.init(with: fileName, fileData: fileData)
    }
    
    init(with fileName:String, fileData:Data){
        self.fileName = fileName
        
        self.fileSize = fileData.count
        guard let magicType = MagicType(fileData) else { fatalError() }
        switch magicType{
        case .macho32, .macho64:
            self.machos = [JYMacho(machoDataRaw: fileData, machoFileName: fileName )]
        case .ar:
            #warning("TODO")
            self.machos = [JYMacho(machoDataRaw: fileData, machoFileName: fileName )]
        case .fat:
            #warning("TODO")
            self.machos = [JYMacho(machoDataRaw: fileData, machoFileName: fileName )]
        }
    }
}
