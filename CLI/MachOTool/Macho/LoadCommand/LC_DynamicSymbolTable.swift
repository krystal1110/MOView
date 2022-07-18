//
//  DynamicSymbolTableCompont.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/15.
//

import Foundation

//dysymtab_command



extension MachOLoadCommand {
    public struct LC_DynamicSymbolTable: MachOLoadCommandType {
        
        public var name: String
        public var command: dysymtab_command? = nil;
        
        init(command: dysymtab_command) {
            let types =   LoadCommandType(rawValue: command.cmd)
            self.name = types?.name ?? " Unknow Command Name "
            self.command = command
        }
        
        init(loadCommand: MachOLoadCommand) {
            let command = loadCommand.data.extract(dysymtab_command.self, offset: loadCommand.offset)
            self.init(command: command)
        }
    }
}







//
//class DynamicSymbolTableCompont: JYLoadCommand {
//    let ilocalsym: UInt32 /* index to local symbols */
//    let nlocalsym: UInt32 /* number of local symbols */
//
//    let iextdefsym: UInt32 /* index to externally defined symbols */
//    let nextdefsym: UInt32 /* number of externally defined symbols */
//
//    let iundefsym: UInt32 /* index to undefined symbols */
//    let nundefsym: UInt32 /* number of undefined symbols */
//
//    let tocoff: UInt32 /* file offset to table of contents */
//    let ntoc: UInt32 /* number of entries in table of contents */
//
//    let modtaboff: UInt32 /* file offset to module table */
//    let nmodtab: UInt32 /* number of module table entries */
//
//    let extrefsymoff: UInt32 /* offset to referenced symbol table */
//    let nextrefsyms: UInt32 /* number of referenced symbol table entries */
//
//    let indirectsymoff: UInt32 /* file offset to the indirect symbol table */
//    let nindirectsyms: UInt32 /* number of indirect symbol table entries */
//
//    let extreloff: UInt32 /* offset to external relocation entries */
//    let nextrel: UInt32 /* number of external relocation entries */
//
//    let locreloff: UInt32 /* offset to local relocation entries */
//    let nlocrel: UInt32 /* number of local relocation entries */
//
//    required init(with data: Data, commandType: LoadCommandType, translationStore: TranslationRead? = nil) {
//        let translationStore = TranslationRead(machoDataSlice: data).skip(.quadWords)
//
//        ilocalsym =
//            translationStore.translate(next: .doubleWords, dataInterpreter: DataInterpreterPreset.UInt32, itemContentGenerator: { value in
//                ExplanationModel(description: "Start Index of Local Symbols ",
//                                 explanation: "\(value)")
//            })
//
//        nlocalsym =
//            translationStore.translate(next: .doubleWords, dataInterpreter: DataInterpreterPreset.UInt32, itemContentGenerator: { value in
//                ExplanationModel(description: "Number of Local Symbols ", explanation: "\(value)")
//            })
//
//        iextdefsym =
//            translationStore.translate(next: .doubleWords, dataInterpreter: DataInterpreterPreset.UInt32, itemContentGenerator: { value in
//                ExplanationModel(description: "Start Index of External Defined Symbols ", explanation: "\(value)")
//            })
//
//        nextdefsym =
//            translationStore.translate(next: .doubleWords, dataInterpreter: DataInterpreterPreset.UInt32, itemContentGenerator: { value in
//                ExplanationModel(description: "Number of External Defined Symbols ", explanation: "\(value)")
//            })
//
//        iundefsym =
//            translationStore.translate(next: .doubleWords, dataInterpreter: DataInterpreterPreset.UInt32, itemContentGenerator: { value in
//                ExplanationModel(description: "Start Index of Undefined Symbols ",
//                                 explanation: "\(value)")
//            })
//
//        nundefsym =
//            translationStore.translate(next: .doubleWords, dataInterpreter: DataInterpreterPreset.UInt32, itemContentGenerator: { value in
//                ExplanationModel(description: "Number of Undefined Symbols ", explanation: "\(value)")
//            })
//
//        tocoff =
//            translationStore.translate(next: .doubleWords, dataInterpreter: DataInterpreterPreset.UInt32, itemContentGenerator: { value in
//                ExplanationModel(description: "file offset to table of contents ", explanation: "\(value.hex)")
//            })
//
//        ntoc =
//            translationStore.translate(next: .doubleWords, dataInterpreter: DataInterpreterPreset.UInt32, itemContentGenerator: { value in
//                ExplanationModel(description: "number of entries in table of contents ", explanation: "\(value)")
//            })
//
//        modtaboff =
//            translationStore.translate(next: .doubleWords, dataInterpreter: DataInterpreterPreset.UInt32, itemContentGenerator: { value in
//                ExplanationModel(description: "file offset to module table ", explanation: "\(value.hex)")
//            })
//
//        nmodtab =
//            translationStore.translate(next: .doubleWords, dataInterpreter: DataInterpreterPreset.UInt32, itemContentGenerator: { value in
//                ExplanationModel(description: "number of module table entries ", explanation: "\(value)")
//            })
//
//        extrefsymoff =
//            translationStore.translate(next: .doubleWords, dataInterpreter: DataInterpreterPreset.UInt32, itemContentGenerator: { value in
//                ExplanationModel(description: "offset to referenced symbol table ", explanation: "\(value.hex)")
//            })
//
//        nextrefsyms =
//            translationStore.translate(next: .doubleWords, dataInterpreter: DataInterpreterPreset.UInt32, itemContentGenerator: { value in
//                ExplanationModel(description: "number of referenced symbol table entries ", explanation: "\(value)")
//            })
//
//        indirectsymoff =
//            translationStore.translate(next: .doubleWords, dataInterpreter: DataInterpreterPreset.UInt32, itemContentGenerator: { value in
//                ExplanationModel(description: "file offset to the indirect symbol table ", explanation: "\(value.hex)")
//            })
//
//        nindirectsyms =
//            translationStore.translate(next: .doubleWords, dataInterpreter: DataInterpreterPreset.UInt32, itemContentGenerator: { value in
//                ExplanationModel(description: "number of indirect symbol table entries ", explanation: "\(value)")
//            })
//
//        extreloff =
//            translationStore.translate(next: .doubleWords, dataInterpreter: DataInterpreterPreset.UInt32, itemContentGenerator: { value in
//                ExplanationModel(description: "offset to external relocation entries ", explanation: "\(value.hex)")
//            })
//
//        nextrel =
//            translationStore.translate(next: .doubleWords, dataInterpreter: DataInterpreterPreset.UInt32, itemContentGenerator: { value in
//                ExplanationModel(description: "number of external relocation entries ", explanation: "\(value)")
//            })
//
//        locreloff =
//            translationStore.translate(next: .doubleWords, dataInterpreter: DataInterpreterPreset.UInt32, itemContentGenerator: { value in
//                ExplanationModel(description: "offset to local relocation entries ", explanation: "\(value.hex)")
//            })
//
//        nlocrel =
//            translationStore.translate(next: .doubleWords, dataInterpreter: DataInterpreterPreset.UInt32, itemContentGenerator: { value in
//                ExplanationModel(description: "number of local relocation entries ", explanation: "\(value)")
//            })
//
//        super.init(with: data, commandType: commandType, translationStore: translationStore)
//    }
//}
//
///*
// struct dysymtab_command {
//     uint32_t cmd;    /* LC_DYSYMTAB */
//     uint32_t cmdsize;    /* sizeof(struct dysymtab_command) */
//
//     /*
//      * The symbols indicated by symoff and nsyms of the LC_SYMTAB load command
//      * are grouped into the following three groups:
//      *    local symbols (further grouped by the module they are from)
//      *    defined external symbols (further grouped by the module they are from)
//      *    undefined symbols
//      *
//      * The local symbols are used only for debugging.  The dynamic binding
//      * process may have to use them to indicate to the debugger the local
//      * symbols for a module that is being bound.
//      *
//      * The last two groups are used by the dynamic binding process to do the
//      * binding (indirectly through the module table and the reference symbol
//      * table when this is a dynamically linked shared library file).
//      */
//     uint32_t ilocalsym;    /* index to local symbols */
//     uint32_t nlocalsym;    /* number of local symbols */
//
//     uint32_t iextdefsym; /* index to externally defined symbols */
//     uint32_t nextdefsym; /* number of externally defined symbols */
//
//     uint32_t iundefsym;    /* index to undefined symbols */
//     uint32_t nundefsym;    /* number of undefined symbols */
//
//     /*
//      * For the for the dynamic binding process to find which module a symbol
//      * is defined in the table of contents is used (analogous to the ranlib
//      * structure in an archive) which maps defined external symbols to modules
//      * they are defined in.  This exists only in a dynamically linked shared
//      * library file.  For executable and object modules the defined external
//      * symbols are sorted by name and is use as the table of contents.
//      */
//     uint32_t tocoff;    /* file offset to table of contents */
//     uint32_t ntoc;    /* number of entries in table of contents */
//
//     /*
//      * To support dynamic binding of "modules" (whole object files) the symbol
//      * table must reflect the modules that the file was created from.  This is
//      * done by having a module table that has indexes and counts into the merged
//      * tables for each module.  The module structure that these two entries
//      * refer to is described below.  This exists only in a dynamically linked
//      * shared library file.  For executable and object modules the file only
//      * contains one module so everything in the file belongs to the module.
//      */
//     uint32_t modtaboff;    /* file offset to module table */
//     uint32_t nmodtab;    /* number of module table entries */
//
//     /*
//      * To support dynamic module binding the module structure for each module
//      * indicates the external references (defined and undefined) each module
//      * makes.  For each module there is an offset and a count into the
//      * reference symbol table for the symbols that the module references.
//      * This exists only in a dynamically linked shared library file.  For
//      * executable and object modules the defined external symbols and the
//      * undefined external symbols indicates the external references.
//      */
//     uint32_t extrefsymoff;    /* offset to referenced symbol table */
//     uint32_t nextrefsyms;    /* number of referenced symbol table entries */
//
//     /*
//      * The sections that contain "symbol pointers" and "routine stubs" have
//      * indexes and (implied counts based on the size of the section and fixed
//      * size of the entry) into the "indirect symbol" table for each pointer
//      * and stub.  For every section of these two types the index into the
//      * indirect symbol table is stored in the section header in the field
//      * reserved1.  An indirect symbol table entry is simply a 32bit index into
//      * the symbol table to the symbol that the pointer or stub is referring to.
//      * The indirect symbol table is ordered to match the entries in the section.
//      */
//     uint32_t indirectsymoff; /* file offset to the indirect symbol table */
//     uint32_t nindirectsyms;  /* number of indirect symbol table entries */
//
//     /*
//      * To support relocating an individual module in a library file quickly the
//      * external relocation entries for each module in the library need to be
//      * accessed efficiently.  Since the relocation entries can't be accessed
//      * through the section headers for a library file they are separated into
//      * groups of local and external entries further grouped by module.  In this
//      * case the presents of this load command who's extreloff, nextrel,
//      * locreloff and nlocrel fields are non-zero indicates that the relocation
//      * entries of non-merged sections are not referenced through the section
//      * structures (and the reloff and nreloc fields in the section headers are
//      * set to zero).
//      *
//      * Since the relocation entries are not accessed through the section headers
//      * this requires the r_address field to be something other than a section
//      * offset to identify the item to be relocated.  In this case r_address is
//      * set to the offset from the vmaddr of the first LC_SEGMENT command.
//      * For MH_SPLIT_SEGS images r_address is set to the the offset from the
//      * vmaddr of the first read-write LC_SEGMENT command.
//      *
//      * The relocation entries are grouped by module and the module table
//      * entries have indexes and counts into them for the group of external
//      * relocation entries for that the module.
//      *
//      * For sections that are merged across modules there must not be any
//      * remaining external relocation entries for them (for merged sections
//      * remaining relocation entries must be local).
//      */
//     uint32_t extreloff;    /* offset to external relocation entries */
//     uint32_t nextrel;    /* number of external relocation entries */
//
//     /*
//      * All the local relocation entries are grouped together (they are not
//      * grouped by their module since they are only used if the object is moved
//      * from it staticly link edited address).
//      */
//     uint32_t locreloff;    /* offset to local relocation entries */
//     uint32_t nlocrel;    /* number of local relocation entries */
//
// };
// **/
