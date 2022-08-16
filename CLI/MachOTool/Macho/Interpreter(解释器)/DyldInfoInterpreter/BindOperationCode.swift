//
//  BindOperationCode.swift
//  mocha (macOS)
//
//  Created by white on 2022/1/13.
//

import Foundation

//#define BIND_SPECIAL_DYLIB_SELF                     0
//#define BIND_SPECIAL_DYLIB_MAIN_EXECUTABLE            -1
//#define BIND_SPECIAL_DYLIB_FLAT_LOOKUP                -2
//#define BIND_SPECIAL_DYLIB_WEAK_LOOKUP                -3
//
//#define BIND_SYMBOL_FLAGS_WEAK_IMPORT                0x1
//#define BIND_SYMBOL_FLAGS_NON_WEAK_DEFINITION            0x8

// FIXME: these flags are not explained in Mocha yet.

enum BindImmediateType {
    
    case threadedSubSetBindOrdinalTableSizeULEB
    case threadedSubApple
    case bindTypePointer
    case bindTypeTextAbsolute32
    case bindTypeTextPCRel32
    
    case rawValue(UInt8)
    
    var readable: String {
        switch self {
        case .threadedSubSetBindOrdinalTableSizeULEB:
            return "BIND_SUBOPCODE_THREADED_SET_BIND_ORDINAL_TABLE_SIZE_ULEB"
        case .threadedSubApple:
            return "BIND_SUBOPCODE_THREADED_APPLY"
        case .bindTypePointer:
            return "BIND_TYPE_POINTER"
        case .bindTypeTextAbsolute32:
            return "BIND_TYPE_TEXT_ABSOLUTE32"
        case .bindTypeTextPCRel32:
            return "BIND_TYPE_TEXT_PCREL32"
        case .rawValue(let value):
            return "\(value)"
        }
    }
}

enum BindOperationType: UInt8 {
    case done = 0x00
    case setDylibOrdinalImm = 0x10
    case setDylibOrdinalULEB = 0x20
    case setDylibSpecialImm = 0x30
    case setSymbolTrailingFlagsImm = 0x40
    case setTypeImm = 0x50
    case setAddEndSLEB = 0x60
    case setSegmentAndOffsetULEB = 0x70
    case addAddrULEB = 0x80
    case doBind = 0x90
    case doBindAddAddrULEB = 0xa0
    case doBindAddAddrImmScaled = 0xb0
    case doBindULEBTimesSkippingULEB = 0xc0
    case threaded = 0xd0
    
    var readable: String {
        switch self {
        case .done:
            // binding 结束标志
            return "BIND_OPCODE_DONE"
        
        case .setDylibOrdinalImm:
            // 立即数（immediate）设置为依赖库索引 Ordinal，即 Load command 中的 LC_LOAD_DYLIB 按顺序排列的库，
            return "BIND_OPCODE_SET_DYLIB_ORDINAL_IMM"
       
        case .setDylibOrdinalULEB:
            // 将随后的 ULEB128 值设置为依赖库索引 Ordinal
            return "BIND_OPCODE_SET_DYLIB_ORDINAL_ULEB"
        
        case .setDylibSpecialImm:
            // 根据立即数计算索引 Ordinal
            return "BIND_OPCODE_SET_DYLIB_SPECIAL_IMM"
        
        case .setSymbolTrailingFlagsImm:
            // 后面的数据为symbol字符串,也就是低4bit为字符串
            return "BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM"
        
        case .setTypeImm:
            // 立即数（immediate）设置为 type，分为以下类型：
            //BIND_TYPE_POINTER 1
            //BIND_TYPE_TEXT_ABSOLUTE32 2
            //BIND_TYPE_TEXT_PCREL32 3
            return "BIND_OPCODE_SET_TYPE_IMM"
        
        case .setAddEndSLEB:
            // 设置上下文的加数（addend）为随后的 SLEB128 值
            return "BIND_OPCODE_SET_ADDEND_SLEB"
        
        case .setSegmentAndOffsetULEB:
            // 立即数（immediate）设置为当前上下文的 segment 索引，从而计算出当前 segment 首地址 segmentStartAddress
            return "BIND_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB"
        
        case .addAddrULEB:
            return "BIND_OPCODE_ADD_ADDR_ULEB"
        
        case .doBind:
            // 操作地址 address 向后移动 ULEB128 数据对应的值，即 address += read_uleb128(p, end);
            return "BIND_OPCODE_DO_BIND"
        
        case .doBindAddAddrULEB:
            // 利用之前计算的上下文数据执行 binding
            // 操作地址 address 向后移动一个指针宽度
            return "BIND_OPCODE_DO_BIND_ADD_ADDR_ULEB"
        
        case .doBindAddAddrImmScaled:
            // 利用之前计算的上下文数据执行 binding
            // 操作地址 address 向后移动立即数倍数的指针宽度（immediate*sizeof(intptr_t)）再加一个指针宽度
            return "BIND_OPCODE_DO_BIND_ADD_ADDR_IMM_SCALED"
        
        case .doBindULEBTimesSkippingULEB:
           // 连续读取两个 ULEB128 值，先后为循环次数 count 和跳过的字节数 skip
           // 执行循环，根据上下文数据执行 binding 操作
           // 操作地址 address 向后移动 skip 加指针宽度的偏移量，即 address += skip + sizeof(uintptr_t);
            return "BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB"
        
        case .threaded:
            return "BIND_OPCODE_THREADED"
        }
    }
}

struct BindOperationCode: OperationCodeProtocol {
    
    let bindOperationType: BindOperationType
    let bindImmediateType: BindImmediateType
    let hasTrailingCString: Bool
    
    init(operationCodeValue: UInt8, immediateValue: UInt8) {
        guard let bindOperationType = BindOperationType(rawValue: operationCodeValue) else {
            // unknown opcode. The latest open sourced dyld doesn's recognize this value neither 😄
            // contact the author
            fatalError()
        }
        self.bindOperationType = bindOperationType
        self.hasTrailingCString = bindOperationType == .setSymbolTrailingFlagsImm
        
        switch bindOperationType {
        case .setTypeImm:
            switch immediateValue {
            case 1:
                self.bindImmediateType = .bindTypePointer
            case 2:
                self.bindImmediateType = .bindTypeTextAbsolute32
            case 3:
                self.bindImmediateType = .bindTypeTextPCRel32
            default:
                fatalError()
            }
        case .threaded:
            switch immediateValue {
            case 0:
                self.bindImmediateType = .threadedSubSetBindOrdinalTableSizeULEB
            case 1:
                self.bindImmediateType = .threadedSubApple
            default:
                fatalError()
            }
        default:
            self.bindImmediateType = .rawValue(immediateValue)
        }
    }
    
    func operationReadable() -> String {
        return self.bindOperationType.readable
    }
    
    func immediateReadable() -> String {
        return self.bindImmediateType.readable
    }
    
    var numberOfTrailingLEB: Int {
        switch self.bindOperationType {
        case .setDylibOrdinalULEB, .setAddEndSLEB, .setSegmentAndOffsetULEB, .addAddrULEB, .doBindAddAddrULEB:
            return 1
        case .doBindULEBTimesSkippingULEB:
            return 2
        case .threaded:
            switch self.bindImmediateType {
            case .threadedSubSetBindOrdinalTableSizeULEB:
                return 1
            default:
                return 0
            }
        default:
            return 0
        }
    }
    
    var trailingLEBType: LEBType {
        switch self.bindOperationType {
        case .setAddEndSLEB:
            return .signed
        default:
            return .unsigned
        }
    }
}
