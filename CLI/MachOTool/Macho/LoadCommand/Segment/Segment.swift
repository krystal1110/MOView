//
//  Segment.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/24.
//

import Foundation
import MachO

 
extension MachOLoadCommand {
    public struct Segment: MachOLoadCommandType {
        
        public var name: String
        public var command64: segment_command_64? = nil; // neilwu added
        public var sections:[Section64] = []
        
        
        init(command: segment_command_64, displayStore:DisplayStore) {
            var segname = command.segname
            self.name =  Utils.readCharToString(&segname)
            self.command64 = command
            
            
 
            let _  =  displayStore.translate(from: 8, length: MemoryLayout<(CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar)>.size, dataInterpreter: {$0.utf8String!.spaceRemoved}) { segmentName in
                ExplanationModel(description: "Segment Name", explanation:segmentName)
            }
            
            let _  =  displayStore.translate(from: 24, length: MemoryLayout<UInt64>.size, dataInterpreter: {$0.UInt64}) { value in
                ExplanationModel(description: "VM Address", explanation:value.hex)
            }
            
            let _  =  displayStore.translate(from: 32, length: MemoryLayout<UInt64>.size, dataInterpreter: {$0.UInt64}) { value in
                ExplanationModel(description: "VM Size", explanation:value.hex)
            }
 
            let _  =  displayStore.translate(from: 40, length: MemoryLayout<UInt64>.size, dataInterpreter: {$0.UInt64}) { value in
                ExplanationModel(description: "File Offset", explanation:value.hex)
            }
            
            let _  =  displayStore.translate(from: 48, length: MemoryLayout<UInt64>.size, dataInterpreter: {$0.UInt64}) { value in
                ExplanationModel(description: "File Size", explanation:value.hex)
            }
            
            let _  =  displayStore.translate(from: 56, length: MemoryLayout<vm_prot_t>.size, dataInterpreter: {$0.UInt32}) { value in
                ExplanationModel(description: "Maximum VM protection", explanation:VMProtection(raw: value).explanation)
            }

            
            let _  =  displayStore.translate(from: 60, length: MemoryLayout<vm_prot_t>.size, dataInterpreter: {$0.UInt32}) { value in
                ExplanationModel(description: "Initial VM protection", explanation:VMProtection(raw: value).explanation)
            }
            
            let _  =  displayStore.translate(from: 64, length: MemoryLayout<UInt32>.size, dataInterpreter: {$0.UInt32}) { value in
                ExplanationModel(description: "Number of Sections", explanation:value.hex)
            }
        }
 
        init(loadCommand: MachOLoadCommand) {
            
                var segmentCommand64:segment_command_64 = loadCommand.data.extract(segment_command_64.self, offset: loadCommand.offset)
            
                if loadCommand.byteSwapped {
                    swap_segment_command_64(&segmentCommand64, byteSwappedOrder)
                }
           
            self.init(command: segmentCommand64, displayStore:loadCommand.displayStore)
                
                if (segmentCommand64.nsects <= 0) {
                    return;
                }
                let sectionOffset = loadCommand.offset + 0x48; // 0x48=sizeof(segment_command_64)
                
                for i in 0..<segmentCommand64.nsects {
                    let offset = sectionOffset + 0x50 * Int(i);
                    //print("\(self.name) \(i)", offset.hex )
                    let section:section_64 = loadCommand.data.extract(section_64.self, offset: offset)
                    
                    let sec = Section64(section: section);
                    self.sections.append(sec);
                }
            
        }
        
        
    }
 
}

 
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
