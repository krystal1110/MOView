//
//  JYSegment.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/10.
//

import Foundation


/*
 * The 64-bit segment load command indicates that a part of this file is to be
 * mapped into a 64-bit task's address space.  If the 64-bit segment has
 * sections then section_64 structures directly follow the 64-bit segment
 * command and their size is reflected in cmdsize.
 
struct segment_command_64 { /* for 64-bit architectures */
    uint32_t    cmd;        /* LC_SEGMENT_64 */
    uint32_t    cmdsize;    /* includes sizeof section_64 structs */
    char        segname[16];    /* segment name */
    uint64_t    vmaddr;        /* memory address of this segment */
    uint64_t    vmsize;        /* memory size of this segment */
    uint64_t    fileoff;    /* file offset of this segment */
    uint64_t    filesize;    /* amount to map from the file */
    vm_prot_t    maxprot;    /* maximum VM protection */
    vm_prot_t    initprot;    /* initial VM protection */
    uint32_t    nsects;        /* number of sections in segment */
    uint32_t    flags;        /* flags */
};
 
*/

class JYSegment : JYLoadCommand{
    let is64Bit: Bool
    let segname: String
    let vmaddr: UInt64
    let vmsize: UInt64
    let fileoff: UInt64
    let filesize: UInt64
    let maxprot: UInt32
    let initprot: UInt32
    let nsects: UInt32
    let flags: UInt32
    let sectionHeaders: [JYSectionHeader64]
    
    required init(with dataSlice: JYDataSlice, commandType: LoadCommandType, translationStore: JYTranslationRead? = nil) {
        
        let is64Bit = commandType == LoadCommandType.segment64
        self.is64Bit = is64Bit;
        let translationStore = JYTranslationRead(machoDataSlice: dataSlice).skip(.quadWords)

        self.segname = translationStore.translate(next: .rawNumber(16),
                                                    dataInterpreter: { $0.utf8String!.spaceRemoved /* Unlikely Error */ },
                                                        itemContentGenerator: { segmentName in ExplanationModel(description: "Segment Name", explanation: segmentName) })
        
        self.vmaddr = translationStore.translate(next: (is64Bit ? .quadWords : .doubleWords),
                                                 dataInterpreter: { is64Bit ? $0.UInt64 : UInt64($0.UInt32) },
                                               itemContentGenerator: { value in ExplanationModel(description: "Virtual Memory Start Address", explanation: value.hex) })
        
        self.vmsize = translationStore.translate(next: (is64Bit ? .quadWords : .doubleWords),
                                               dataInterpreter: { is64Bit ? $0.UInt64 : UInt64($0.UInt32) },
                                               itemContentGenerator: { value in ExplanationModel(description: "Virtual Memory Size", explanation: value.hex) })
        
        self.fileoff = translationStore.translate(next: (is64Bit ? .quadWords : .doubleWords),
                                                         dataInterpreter: { is64Bit ? $0.UInt64 : UInt64($0.UInt32) },
                                                         itemContentGenerator: { value in ExplanationModel(description: "File Offset", explanation: value.hex) })
        
        self.filesize = translationStore.translate(next: (is64Bit ? .quadWords : .doubleWords),
                                               dataInterpreter: { is64Bit ? $0.UInt64 : UInt64($0.UInt32) },
                                               itemContentGenerator: { value in ExplanationModel(description: "Size to Map into Memory", explanation: value.hex) })
        
        self.maxprot = translationStore.translate(next: .doubleWords,
                                               dataInterpreter: DataInterpreterPreset.UInt32,
                                               itemContentGenerator: { value in ExplanationModel(description: "Maximum VM Protection", explanation: VMProtection(raw: value).explanation) })
        
        self.initprot = translationStore.translate(next: .doubleWords,
                                               dataInterpreter: DataInterpreterPreset.UInt32,
                                               itemContentGenerator: { value in ExplanationModel(description: "Initial VM Protection", explanation: VMProtection(raw: value).explanation) })
        
        self.nsects = translationStore.translate(next: .doubleWords,
                                               dataInterpreter: DataInterpreterPreset.UInt32,
                                               itemContentGenerator: { value in ExplanationModel(description: "Number of Sections", explanation: "\(value)") })
        
        self.flags = translationStore.translate(next: .doubleWords,
                                              dataInterpreter: { $0.UInt32 },
                                              itemContentGenerator: { flags in ExplanationModel(description: "Flags",
                                                                                                      explanation: JYSegment.flags(for: flags))})
        
        var sectionHeaders: [JYSectionHeader64] = []
        for index in 0..<Int(nsects) {
            // section header data length for 32-bit is 68, and 64-bit 80
            let sectionHeaderLength = is64Bit ? 80 : 68
            let segmentCommandSize = is64Bit ? 72 : 56
            let sectionHeaderData = dataSlice.interception(from: segmentCommandSize + index * sectionHeaderLength, length: sectionHeaderLength)
            let sectionHeader = JYSectionHeader64(is64Bit: is64Bit, data: sectionHeaderData)
            sectionHeaders.append(sectionHeader)
        }
        self.sectionHeaders = sectionHeaders
        super.init(with: dataSlice, commandType: commandType, translationStore: translationStore)
    }
    
    
    
    
    
    
    static func flags(for flags: UInt32) -> String {
        
    //        /* Constants for the flags field of the segment_command */
    //        #define    SG_HIGHVM    0x1    /* the file contents for this segment is for
    //                           the high part of the VM space, the low part
    //                           is zero filled (for stacks in core files) */
    //        #define    SG_FVMLIB    0x2    /* this segment is the VM that is allocated by
    //                           a fixed VM library, for overlap checking in
    //                           the link editor */
    //        #define    SG_NORELOC    0x4    /* this segment has nothing that was relocated
    //                           in it and nothing relocated to it, that is
    //                           it maybe safely replaced without relocation*/
    //        #define SG_PROTECTED_VERSION_1    0x8 /* This segment is protected.  If the
    //                               segment starts at file offset 0, the
    //                               first page of the segment is not
    //                               protected.  All other pages of the
    //                               segment are protected. */
    //        #define SG_READ_ONLY    0x10 /* This segment is made read-only after fixups */
        
        var ret: [String] = []
        if (flags & 0x1 != 0) { ret.append("SG_HIGHVM") }
        
        if (flags & 0x2 != 0) { ret.append("SG_FVMLIB") }
        
        if (flags & 0x4 != 0) { ret.append("SG_NORELOC") }
        
        if (flags & 0x8 != 0) { ret.append("SG_PROTECTED_VERSION_1") }
        
        if (flags & 0x10 != 0) { ret.append("SG_READ_ONLY") }
            
        if ret.isEmpty { ret.append("NONE") }

        return ret.joined(separator: "\n")
    }

    
    
}


struct DataInterpreterPreset {
    static func UInt32(_ data: Data) -> Swift.UInt32 {
        return data.UInt32
    }
}



// 权限
struct VMProtection {
    
    let raw: UInt32
    let readable: Bool
    let writable: Bool
    let executable: Bool
    
    init(raw: UInt32) {
        self.raw = raw
        self.readable = raw & 0x01 != 0
        self.writable = raw & 0x02 != 0
        self.executable = raw & 0x04 != 0
    }
    
    var explanation: String {
        if readable && writable && executable { return "VM_PROT_ALL" }
        if readable && writable { return "VM_PROT_DEFAULT" }
        var ret: [String] = []
        if readable { ret.append("VM_PROT_READ") }
        if writable { ret.append("VM_PROT_WRITE") }
        if executable { ret.append("VM_PROT_EXECUTE") }
        if ret.isEmpty { ret.append("VM_PROT_NONE") }
        return ret.joined(separator: ",")
    }
}

 
