//
//  JYSymbolTableEntryModel.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/17.
//

import Foundation

struct JYSymbolTableEntryModel: MachoExplainModel {

    let indexInStringTableRange: Range<Int>
    let indexInStringTable: UInt32
    let symbolType: SymbolType
    let isPrivateExternalSymbol: Bool

    let isExternalSymbol: Bool

    let nSect: UInt8
    let nDesc: Swift.UInt16
    let nValue: UInt64

    let translaitonItems: [ExplanationItem]

    init(with data: DataSlice, is64Bit: Bool) {
        var translaitonItems: [ExplanationItem] = []

        let indexInStringTable = data.interception(from: .zero, length: 4).raw.UInt32
        self.indexInStringTable = indexInStringTable

        indexInStringTableRange = data.absoluteRange(.zero, 4)
        let nTypeByteRange = data.absoluteRange(4, 1)
        let nTypeRaw = data.interception(from: 4, length: 1).raw.UInt8
        let symbolType = SymbolType(nTypeRaw: nTypeRaw)
        self.symbolType = symbolType

        let isPrivateExternalSymbol = (nTypeRaw & 0x10) != 0 // 0x10 == N_PEXT mask == 00010000 /* private external symbol bit */
        self.isPrivateExternalSymbol = isPrivateExternalSymbol
        let isExternalSymbol = (nTypeRaw & 0x01) != 0 // 0x01 == N_EXT mask == 00000001 /* external symbol bit, set for external symbols */
        self.isExternalSymbol = isExternalSymbol

        /*
         * n_sect
         * n_desc
         * n_value
         */

        let nSect = data.interception(from: 5, length: 1).raw.UInt8
        let nDesc = data.interception(from: 6, length: 2).raw.UInt16
        let nValueRawData = data.interception(from: 8, length: is64Bit ? 8 : 4).raw
        let nValue = is64Bit ? nValueRawData.UInt64 : UInt64(nValueRawData.UInt32)
        self.nSect = nSect
        self.nDesc = nDesc
        self.nValue = nValue

        let symbolTypeDesp: String = "Symbol Type"
        var symbolTypeExplanation: String = symbolType.readable

        let nSectDesp: String = "Section Ordinal"
        var nSectExplanation: String = "\(nSect)"

        let nDescDesp: String = "Descriptions"
//        let nDescExplanation: String = SymbolTableEntry.flagsFrom(nDesc: nDesc, symbolType: symbolType).joined(separator: "\n")
//
//        var nValueDesp: String = "Value"
//        var nValueExplanation: String = "\(nValue)"
//        var nValueExtraDesp: String?
//        var nValueExtraExplanation: String?

//        switch symbolType {
//        case .undefined:
//            nSectExplanation = "0 (NO_SECT)"
//        case .absolute:
//            nSectExplanation = "0 (NO_SECT)"
//        case .section:
//            symbolTypeExplanation += (machoSearchSource.sectionName(at: Int(nSect)) + " (N_SECT)")
//        case .indirect:
//            nValueDesp = "String table offset"
//            nValueExplanation = nValue.hex
//            nValueExtraDesp = "Referred string"
//            nValueExtraExplanation = machoSearchSource.stringInStringTable(at: Int(nValue))
//        default:
//            break
//        }
        self.translaitonItems = translaitonItems
    }

    static func modelSize(is64Bit: Bool) -> Int {
        return is64Bit ? 16 : 12
    }

    static func numberOfExplanationItem() -> Int {
        return 6
    }

    //    let machoSearchSource: MachoSearchSource

    //    let indexInStringTableRange: Range<Int>
    //    let indexInStringTable: UInt32

    //    let symbolType: SymbolType
}

enum StabType: UInt8 {
    case gsym = 0x20 /* global symbol */
    case fname = 0x22 /* F77 function name */
    case fun = 0x24 /* procedure name */
    case stsym = 0x26 /* data segment variable */
    case lcsym = 0x28 /* bss segment variable */
    case main = 0x2A /* main function name */
    case pc = 0x30 /* global Pascal symbol */
    case rsym = 0x40 /* register variable */
    case sline = 0x44 /* text segment line number */
    case dsline = 0x46 /* data segment line number */
    case bsline = 0x48 /* bss segment line number */
    case ssym = 0x60 /* structure/union element */
    case sol = 0x64 /* main source file name */
    case lsym = 0x80 /* stack variable */
    case bincl = 0x82 /* include file beginning */
    case so = 0x84 /* included source file name */
    case psym = 0xA0 /* parameter variable */
    case eincl = 0xA2 /* include file end */
    case entry = 0xA4 /* alternate entry point */
    case lbrac = 0xC0 /* left bracket */
    case excl = 0xC2 /* deleted include file */
    case rbrac = 0xE0 /* right bracket */
    case bcomm = 0xE2 /* begin common */
    case ecomm = 0xE4 /* end common */
    case ecoml = 0xE8 /* end common (local name) */
    case leng = 0xFE /* length of preceding entry */

    var readable: String {
        switch self {
        case .gsym:
            return "N_GSYM"
        case .fname:
            return "N_FNAME"
        case .fun:
            return "N_FUN"
        case .stsym:
            return "N_STSYM"
        case .lcsym:
            return "N_LCSYM"
        case .main:
            return "N_MAIN"
        case .pc:
            return "N_PC"
        case .rsym:
            return "N_RSYM"
        case .sline:
            return "N_SLINE"
        case .dsline:
            return "N_DSLINE"
        case .bsline:
            return "N_BSLINE"
        case .ssym:
            return "N_SSYM"
        case .so:
            return "N_SO"
        case .lsym:
            return "N_LSYM"
        case .bincl:
            return "N_BINCL"
        case .sol:
            return "N_SOL"
        case .psym:
            return "N_PSYM"
        case .eincl:
            return "N_EINCL"
        case .entry:
            return "N_ENTRY"
        case .lbrac:
            return "N_LBRAC"
        case .excl:
            return "N_EXCL"
        case .rbrac:
            return "N_RBRAC"
        case .bcomm:
            return "N_BCOMM"
        case .ecomm:
            return "N_ECOMM"
        case .ecoml:
            return "N_ECOML"
        case .leng:
            return "N_LENG"
        }
    }
}

enum SymbolType {
    case stab(StabType?)
    case undefined
    case absolute
    case section
    case preBound
    case indirect

    var readable: String {
        switch self {
        case .stab:
            return "N_STAB" // FIXME: ignoring detailed stab type
        case .undefined:
            return "Undefined Symbol (N_UNDF)"
        case .absolute:
            return "Absolute Symbol (N_ABS)"
        case .section:
            return "Defined in "
        case .preBound:
            return "Prebound undefined (N_PBUD)"
        case .indirect:
            return "Indirect Symbol (N_INDR)"
        }
    }

    init(nTypeRaw: UInt8) {
        if (nTypeRaw & 0xE0) != 0 {
            let stabType = StabType(rawValue: nTypeRaw)
            self = .stab(stabType)
        } else {
            let n_type_filed = nTypeRaw & 0x0E /* 0x0e == N_TYPE mask == 00001110 */
            switch n_type_filed {
            case 0x0:
                self = .undefined // N_UNDF    0x0        /* undefined, n_sect == NO_SECT */
            case 0x2:
                self = .absolute // N_ABS    0x2        /* absolute, n_sect == NO_SECT */
            case 0xE:
                self = .section // N_SECT    0xe        /* defined in section number n_sect */
            case 0xC:
                self = .preBound // N_PBUD    0xc        /* prebound undefined (defined in a dylib) */
            case 0xA:
                self = .indirect // N_INDR    0xa        /* indirect */
            default:
                /* Unlikely. it must be a symbol */
                fatalError()
            }
        }
    }
}
