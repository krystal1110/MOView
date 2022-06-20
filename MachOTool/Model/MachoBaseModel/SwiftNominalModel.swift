//
//  SwiftNominalModel.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/18.
//

import Foundation

final class SwiftNominalObjField {
    var name: String = ""
    var type: String = ""
    var namePtr: UInt64 = 0
    var typePtr: UInt64 = 0
}

final class SwiftNominalModel {
    
    var typeName: String = ""; // type name
    var contextDescriptorFlag: SwiftContextDescriptorFlags = SwiftContextDescriptorFlags(0); // default
    var fields: [SwiftNominalObjField] = [];
    
    var mangledTypeName: String = ""; // 如果其他人将此类型定义为属性，则可以使用此来检索名称
    var nominalOffset: Int64 = 0; // Context Descriptor offset
    var accessorOffset: UInt64 = 0; // Access Function address
    
    var protocols:[String] = [];
    var superClassName: String = "";
    
    var dumpDefine: String {
        let intent: String = "    ";
        var str: String = "";
        let kind = contextDescriptorFlag.kind;
        str += "\(kind) " + typeName;
        if (!superClassName.isEmpty) {
            str += " : " + superClassName;
        }
        if (protocols.count > 0) {
            let superStr: String = protocols.joined(separator: ",")
            let tmp: String = superClassName.isEmpty ? " : " : "";
            str += tmp + superStr;
        }
        str += " {\n";
        
        str += intent + "// \(contextDescriptorFlag)\n";
        if (accessorOffset > 0) {
            str += intent + "// Access Function at \(accessorOffset.hex) \n";
        }
        
        for field in fields {
            var fs: String = intent;
            if kind == .Enum {
                if (field.type.isEmpty) {
                    fs += "case \(field.name)\n"; // without payload
                } else {
                    let tmp = field.type.hasPrefix("(") ? field.type : "(" + field.type + ")";
                    fs += "case \(field.name)\(tmp)\n"; // enum with payload
                }
                
            } else {
                fs += "let \(field.name): \(field.type);\n";
            }
            str += fs;
        }
        
        str += "}\n";
        
        return str;
    }
    
}








// https://github.com/apple/swift/blob/a021e6ca020e667ce4bc8ee174e2de1cc0d9be73/include/swift/ABI/MetadataValues.h#L1183
enum SwiftContextDescriptorKind: UInt8, CustomStringConvertible {
    /// This context descriptor represents a module.
    case Module = 0
    
    /// This context descriptor represents an extension.
    case Extension = 1
    
    /// This context descriptor represents an anonymous possibly-generic context
    /// such as a function body.
    case Anonymous = 2
    
    /// This context descriptor represents a protocol context.
    case SwiftProtocol = 3
    
    /// This context descriptor represents an opaque type alias.
    case OpaqueType = 4
    
    /// First kind that represents a type of any sort.
    //case Type_First = 16
    
    /// This context descriptor represents a class.
    case Class = 16 // Type_First
    
    /// This context descriptor represents a struct.
    case Struct = 17 // Type_First + 1
    
    /// This context descriptor represents an enum.
    case Enum = 18 // Type_First + 2
    
    /// Last kind that represents a type of any sort.
    case Type_Last = 31
    
    case Unknow = 0xFF // It's not in swift source, this value only used for dump
    
    var description: String {
        switch self {
        case .Module: return "module";
        case .Extension: return "extension";
        case .Anonymous: return "anonymous";
        case .SwiftProtocol: return "protocol";
        case .OpaqueType: return "OpaqueType";
        case .Class: return "class";
        case .Struct: return "struct";
        case .Enum: return "enum";
        case .Type_Last: return "Type_Last";
        case .Unknow: return "unknow";
        }
    }
}

// https://github.com/apple/swift/blob/a021e6ca020e667ce4bc8ee174e2de1cc0d9be73/include/swift/ABI/MetadataValues.h#L1217
struct SwiftContextDescriptorFlags:CustomStringConvertible {
    let value: UInt32
    init(_ value: UInt32) {
        self.value = value;
    }
    
    /// The kind of context this descriptor describes.
    var kind: SwiftContextDescriptorKind {
        if let kind = SwiftContextDescriptorKind(rawValue: UInt8( value & 0x1F ) ) {
            return kind;
        }
        return SwiftContextDescriptorKind.Unknow;
    }
    
    /// Whether the context being described is generic.
    var isGeneric: Bool {
        return (value & 0x80) != 0;
    }
    
    /// Whether this is a unique record describing the referenced context.
    var isUnique: Bool {
        return (value & 0x40) != 0;
    }
    
    /// The format version of the descriptor. Higher version numbers may have
    /// additional fields that aren't present in older versions.
    var version: UInt8 {
        return UInt8((value >> 8) & 0xFF);
    }
    
    /// The most significant two bytes of the flags word, which can have
    /// kind-specific meaning.
    var kindSpecificFlags: UInt16 {
        return UInt16((value >> 16) & 0xFFFF);
    }
    
    var description: String {
        let kindDesc: String = kind.description;
        let kindSpecificFlagsStr: String = String(format: "0x%x", kindSpecificFlags);
        
        var desc: String = "<\(value.hex), \(kindDesc),";
        if isGeneric {
            desc += " isGeneric,"
        }
        if isUnique {
            desc += " isUnique,"
        } else {
            desc += " NotUnique,"
        }
        
        desc += " version \(version), kindSpecificFlags \(kindSpecificFlagsStr)>";
        return desc;
    }
}



