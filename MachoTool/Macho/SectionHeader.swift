//
//  SectionHeader.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/14.
//

import Foundation

/*
 XNU - loader 451
 struct section_64 { /* for 64-bit architectures */
     char        sectname[16];    /* name of this section */
     char        segname[16];    /* segment this section goes in */
     uint64_t    addr;        /* memory address of this section */
     uint64_t    size;        /* size in bytes of this section */
     uint32_t    offset;        /* file offset of this section */
     uint32_t    align;        /* section alignment (power of 2) */
     uint32_t    reloff;        /* file offset of relocation entries */
     uint32_t    nreloc;        /* number of relocation entries */
     uint32_t    flags;        /* flags (section type and attributes)*/
     uint32_t    reserved1;    /* reserved (for offset or index) */
     uint32_t    reserved2;    /* reserved (for count or sizeof) */
     uint32_t    reserved3;    /* reserved */
 };
 **/
/*
 * The flags field of a section structure is separated into two parts a section
 * type and section attributes.  The section types are mutually exclusive (it
 * can only have one type) but the section attributes are not (it may have more
 * than one attribute).
 */
// #define SECTION_TYPE         0x000000ff    /* 256 section types */
// #define SECTION_ATTRIBUTES     0xffffff00    /*  24 section attributes */

struct SectionHeader64 {
    let segment: String
    let section: String
    let addr: UInt64
    let size: UInt64
    let offset: UInt32
    let align: UInt32
    let reloff: UInt32
    let nreloc: UInt32
    let sectionType: SectionType
    let sectionAttributes: SectionAttributes
    let reserved1: UInt32
    let reserved2: UInt32
    let reserved3: UInt32? // exists only for 64 bit

    let is64Bit: Bool
    let data: DataSlice
    let translationStore: TranslationRead

    init(is64Bit: Bool, data: DataSlice) {
        self.is64Bit = is64Bit
        self.data = data

        let translationStore = TranslationRead(machoDataSlice: data)

        section =
            translationStore.translate(next: .rawNumber(16),
                                       dataInterpreter: { $0.utf8String!.spaceRemoved /* Very unlikely crash */ },
                                       itemContentGenerator: { string in ExplanationModel(description: "Section Name", explanation: string) })

        segment =
            translationStore.translate(next: .rawNumber(16),
                                       dataInterpreter: { $0.utf8String!.spaceRemoved /* Very unlikely crash */ },
                                       itemContentGenerator: { string in ExplanationModel(description: "Segment Name", explanation: string) })

        addr =
            translationStore.translate(next: is64Bit ? .quadWords : .doubleWords,
                                       dataInterpreter: { is64Bit ? $0.UInt64 : UInt64($0.UInt32) },
                                       itemContentGenerator: { value in ExplanationModel(description: "Virtual Address", explanation: value.hex) })

        size =
            translationStore.translate(next: is64Bit ? .quadWords : .doubleWords,
                                       dataInterpreter: { is64Bit ? $0.UInt64 : UInt64($0.UInt32) },
                                       itemContentGenerator: { value in ExplanationModel(description: "Section Size", explanation: value.hex) })

        offset =
            translationStore.translate(next: .doubleWords,
                                       dataInterpreter: DataInterpreterPreset.UInt32,
                                       itemContentGenerator: { value in ExplanationModel(description: "File Offset", explanation: value.hex) })

        align =
            translationStore.translate(next: .doubleWords,
                                       dataInterpreter: DataInterpreterPreset.UInt32,
                                       itemContentGenerator: { value in ExplanationModel(description: "Align", explanation: "\(value)") })

        let relocValues: (UInt32, UInt32) =
            translationStore.translate(next: .quadWords,
                                       dataInterpreter: { data in (data.select(from: 0, length: 4).UInt32, data.select(from: 4, length: 4).UInt32) },
                                       itemContentGenerator: { values in ExplanationModel(description: "Reloc Entry Offset / Number", explanation: values.0.hex + " / \(values.1)") })
        reloff = relocValues.0
        nreloc = relocValues.1

        // parse flags
        let flags = data.interception(from: translationStore.translated, length: 4).raw.UInt32
        let rangeOfNextDWords = data.absoluteRange(translationStore.translated, 4)

        let sectionTypeRawValue = flags & 0x000000FF
        guard let sectionType = SectionType(rawValue: sectionTypeRawValue) else {
            print("Unknown section type with raw value: \(sectionTypeRawValue). Contact the author.")
            fatalError()
        }
        self.sectionType = sectionType
        translationStore.append(ExplanationModel(description: "Section Type", explanation: "\(sectionType)"), forRange: rangeOfNextDWords)

        let sectionAttributesRaw = flags & 0xFFFFFF00 // section attributes mask
        let sectionAttributes = SectionAttributes(raw: sectionAttributesRaw)
        translationStore.append(ExplanationModel(description: "Section Attributes", explanation: sectionAttributes.descriptions.joined(separator: "\n")), forRange: rangeOfNextDWords)
        self.sectionAttributes = sectionAttributes

        _ = translationStore.skip(.doubleWords)

        var reserved1Description = "reserved1"
        if sectionType.hasIndirectSymbolTableEntries { reserved1Description = "Indirect Symbol Table Index" }

        var reserved2Description = "reserved2"
        if sectionType == .S_SYMBOL_STUBS { reserved2Description = "Stub Size" }

        let reservedValue: (UInt32, UInt32, UInt32?) =
            translationStore.translate(next: .rawNumber(is64Bit ? 12 : 8),
                                       dataInterpreter: { data -> (UInt32, UInt32, UInt32?) in (data.select(from: 0, length: 4).UInt32,
                                                                                                data.select(from: 4, length: 4).UInt32,
                                                                                                is64Bit ? data.select(from: 8, length: 4).UInt32 : nil) },
                                       itemContentGenerator: { values in ExplanationModel(description: "\(reserved1Description) / \(reserved2Description)" + (values.2 == nil ? "" : " / reserved3"),
                                                                                          explanation: "\(values.0) / \(values.1)" + (values.2 == nil ? "" : " / \(values.2!)")) })

        reserved1 = reservedValue.0
        reserved2 = reservedValue.1
        reserved3 = reservedValue.2

        self.translationStore = translationStore
    }
}

enum SectionType: UInt32 {
    case S_REGULAR = 0
    case S_ZEROFILL
    case S_CSTRING_LITERALS
    case S_4BYTE_LITERALS
    case S_8BYTE_LITERALS
    case S_LITERAL_POINTERS
    case S_NON_LAZY_SYMBOL_POINTERS
    case S_LAZY_SYMBOL_POINTERS
    case S_SYMBOL_STUBS
    case S_MOD_INIT_FUNC_POINTERS
    case S_MOD_TERM_FUNC_POINTERS
    case S_COALESCED
    case S_GB_ZEROFILL
    case S_INTERPOSING
    case S_16BYTE_LITERALS
    case S_DTRACE_DOF
    case S_LAZY_DYLIB_SYMBOL_POINTERS
    case S_THREAD_LOCAL_REGULAR
    case S_THREAD_LOCAL_ZEROFILL
    case S_THREAD_LOCAL_VARIABLES
    case S_THREAD_LOCAL_VARIABLE_POINTERS
    case S_THREAD_LOCAL_INIT_FUNCTION_POINTERS
    case S_INIT_FUNC_OFFSETS

    var hasIndirectSymbolTableEntries: Bool {
        switch self {
        case .S_NON_LAZY_SYMBOL_POINTERS, .S_LAZY_SYMBOL_POINTERS, .S_LAZY_DYLIB_SYMBOL_POINTERS, .S_SYMBOL_STUBS:
            return true
        default:
            return false
        }
    }
}

enum SectionAttribute {
    case S_ATTR_PURE_INSTRUCTIONS
    case S_ATTR_NO_TOC
    case S_ATTR_STRIP_STATIC_SYMS
    case S_ATTR_NO_DEAD_STRIP
    case S_ATTR_LIVE_SUPPORT
    case S_ATTR_SELF_MODIFYING_CODE
    case S_ATTR_DEBUG
    case S_ATTR_SOME_INSTRUCTIONS
    case S_ATTR_EXT_RELOC
    case S_ATTR_LOC_RELOC

    var name: String {
        switch self {
        case .S_ATTR_PURE_INSTRUCTIONS:
            return "S_ATTR_PURE_INSTRUCTIONS"
        case .S_ATTR_NO_TOC:
            return "S_ATTR_NO_TOC"
        case .S_ATTR_STRIP_STATIC_SYMS:
            return "S_ATTR_STRIP_STATIC_SYMS"
        case .S_ATTR_NO_DEAD_STRIP:
            return "S_ATTR_NO_DEAD_STRIP"
        case .S_ATTR_LIVE_SUPPORT:
            return "S_ATTR_LIVE_SUPPORT"
        case .S_ATTR_SELF_MODIFYING_CODE:
            return "S_ATTR_SELF_MODIFYING_CODE"
        case .S_ATTR_DEBUG:
            return "S_ATTR_DEBUG"
        case .S_ATTR_SOME_INSTRUCTIONS:
            return "S_ATTR_SOME_INSTRUCTIONS"
        case .S_ATTR_EXT_RELOC:
            return "S_ATTR_EXT_RELOC"
        case .S_ATTR_LOC_RELOC:
            return "S_ATTR_LOC_RELOC"
        }
    }
}

struct SectionAttributes {
    let raw: UInt32
    let attributes: [SectionAttribute]

    var descriptions: [String] {
        if attributes.isEmpty {
            return ["NONE"]
        } else {
            return attributes.map { $0.name }
        }
    }

    init(raw: UInt32) {
        self.raw = raw
        var attributes: [SectionAttribute] = []
        if raw.bitAnd(0x80000000) { attributes.append(.S_ATTR_PURE_INSTRUCTIONS) }
        if raw.bitAnd(0x40000000) { attributes.append(.S_ATTR_NO_TOC) }
        if raw.bitAnd(0x20000000) { attributes.append(.S_ATTR_STRIP_STATIC_SYMS) }
        if raw.bitAnd(0x10000000) { attributes.append(.S_ATTR_NO_DEAD_STRIP) }
        if raw.bitAnd(0x08000000) { attributes.append(.S_ATTR_LIVE_SUPPORT) }
        if raw.bitAnd(0x04000000) { attributes.append(.S_ATTR_SELF_MODIFYING_CODE) }
        if raw.bitAnd(0x02000000) { attributes.append(.S_ATTR_DEBUG) }
        if raw.bitAnd(0x00000400) { attributes.append(.S_ATTR_SOME_INSTRUCTIONS) }
        if raw.bitAnd(0x00000200) { attributes.append(.S_ATTR_EXT_RELOC) }
        if raw.bitAnd(0x00000100) { attributes.append(.S_ATTR_LOC_RELOC) }
        self.attributes = attributes
    }

    func hasAttribute(_ attri: SectionAttribute) -> Bool {
        return attributes.contains(attri)
    }
}
