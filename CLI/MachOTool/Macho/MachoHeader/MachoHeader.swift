//
//  MachoHeader.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/9.
//

import Foundation
import MachO

/*
 struct mach_header_64 {
     uint32_t    magic;        /* mach magic number identifier */
     cpu_type_t    cputype;    /* cpu specifier */
     cpu_subtype_t    cpusubtype;    /* machine specifier */
     uint32_t    filetype;    /* type of file */
     uint32_t    ncmds;        /* number of load commands */
     uint32_t    sizeofcmds;    /* the size of all the load commands */
     uint32_t    flags;        /* flags */
     uint32_t    reserved;    /* reserved */
 };
 **/


public struct MachOHeader {
    public let magic: UInt32 /* mach magic number identifier */
    public let cputype: cpu_type_t /* cpu specifier */
    //public let cpusubtype: cpu_subtype_t /* machine specifier */
    public let filetype: UInt32 /* type of file */
    //public let ncmds: UInt32 /* number of load commands */
    //public var sizeofcmds: UInt32 /* the size of all the load commands */
    //public var flags: UInt32 /* flags */
    
    public let loadCommandCount: UInt32
    public let loadCommandSize: UInt32
    
    public let size: Int
    
    public init(header: mach_header_64) {
        self.magic = header.magic
        self.cputype = header.cputype
        self.filetype = header.filetype
        self.loadCommandCount = header.ncmds
        self.loadCommandSize = header.sizeofcmds
        self.size = MemoryLayout.size(ofValue: header)
    }
    
    public init(header: mach_header) {
        self.magic = header.magic
        self.cputype = header.cputype
        self.filetype = header.filetype
        self.loadCommandCount = header.ncmds
        self.loadCommandSize = header.sizeofcmds
        self.size = MemoryLayout.size(ofValue: header)
    }
}

 

 
 
