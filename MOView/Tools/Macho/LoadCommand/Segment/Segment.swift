//
//  Segment.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/24.
//

import Foundation
import MachO

 
extension MachOLoadCommand {
     struct Segment: MachOLoadCommandType {
         var displayStore: DisplayStore
         var name: String
         var command64: segment_command_64? = nil; // neilwu added
         var sections:[Section64] = []
        
        init(command: segment_command_64, displayStore:DisplayStore) {
            var segname = command.segname
            self.name =  Utils.readCharToString(&segname)
            self.command64 = command
            self.displayStore = displayStore
            
            let translate  = Translate(dataSlice: displayStore.dataSlice)
            
            let type =   LoadCommandType(rawValue: command.cmd)
    
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 0, 4), model: ExplanationModel(description: "Load Command Type", explanation:type?.name ?? "" )))
            
            translate.insert(item: ExplanationItem(sourceDataRange: DataTool.absoluteRange(with: displayStore.dataSlice, start: 4, 8), model: ExplanationModel(description: "Load Command Size", explanation:command.cmdsize.hex)))
            
            
           let segmentName = translate.translate(from: 8, length: MemoryLayout<(CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar)>.size, dataInterpreter: {$0.utf8String!.spaceRemoved}) { segmentName in
                ExplanationModel(description: "Segment Name", explanation:segmentName)
            }
            
            translate.translate(from: 24, length: MemoryLayout<UInt64>.size, dataInterpreter: {$0.UInt64}) { value in
                ExplanationModel(description: "VM Address", explanation:value.hex)
            }
            
           translate.translate(from: 32, length: MemoryLayout<UInt64>.size, dataInterpreter: {$0.UInt64}) { value in
                ExplanationModel(description: "VM Size", explanation:value.hex)
            }
 
            translate.translate(from: 40, length: MemoryLayout<UInt64>.size, dataInterpreter: {$0.UInt64}) { value in
                ExplanationModel(description: "File Offset", explanation:value.hex)
            }
            
            translate.translate(from: 48, length: MemoryLayout<UInt64>.size, dataInterpreter: {$0.UInt64}) { value in
                ExplanationModel(description: "File Size", explanation:value.hex)
            }
            
            translate.translate(from: 56, length: MemoryLayout<vm_prot_t>.size, dataInterpreter: {$0.UInt32}) { value in
                ExplanationModel(description: "Maximum VM protection", explanation:VMProtection(raw: value).explanation)
            }

            
            translate.translate(from: 60, length: MemoryLayout<vm_prot_t>.size, dataInterpreter: {$0.UInt32}) { value in
                ExplanationModel(description: "Initial VM protection", explanation:VMProtection(raw: value).explanation)
            }
            
            let numberOfSections  =  translate.translate(from: 64, length: MemoryLayout<UInt32>.size, dataInterpreter: {$0.UInt32}) { value in
                ExplanationModel(description: "Number of Sections", explanation:value.hex)
            }
            
            self.displayStore.insert(translate: translate)
            
            for index in 0..<Int(numberOfSections) {
                let sectionHeaderLength = 80
                let segmentCommandSize = 72
                let sectionHeaderData = DataTool.interception(with: self.displayStore.dataSlice, from: segmentCommandSize + index * sectionHeaderLength, length: sectionHeaderLength)
                let sectionHeader = SectionHeader(data: sectionHeaderData)
                
                self.displayStore.insert(translate: sectionHeader.translate)
            }
            
            if let type = type?.name {
                self.displayStore.subTitle = type  + " (\(segmentName)"
            }else{
                self.displayStore.subTitle = segmentName
            }
            
            self.displayStore.extra = "Command Size \(command.cmdsize.hex)"
            
            
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
