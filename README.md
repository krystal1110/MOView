### MOView
###  
`MOView` 是一个 `Swift` 与 `SwiftUI` 搭建的可视化 `Mach-O` 文件查看工具，目前仅支持 `Arm64` `64Bit` 架构

![image](https://user-images.githubusercontent.com/83936557/193203756-00de8f39-b863-4193-b6dc-eff8243ebd4f.png)


#### 开源的
`MOView` 该项目是用于学习为主的，如果有任何问题，欢迎交流

### 计划:

✅: 支持
🌀: 正在准备中
🛠: 待优化
❌: 不支持

|  Macho Component   | Supported  |
|  ----  | ----  |
| Macho Header  | ✅ |
| (Load Command) LC_SEGMENT | ✅ |
| (Load Command) LC_SYMTAB | ✅ |
| (Load Command) LC_SYMSEG | ❌ |
| (Load Command) LC_IDFVMLIB | ✅ |
| (Load Command) LC_DYSYMTAB | ✅ |
| (Load Command) LC_LOAD_DYLIB | ✅ |
| (Load Command) LC_ID_DYLIB | ✅ |
| (Load Command) LC_LOAD_DYLINKER | ✅ |
| (Load Command) LC_ID_DYLINKER | ✅ |
| (Load Command) LC_PREBOUND_DYLIB | ✅ |
| (Load Command) LC_LOAD_WEAK_DYLIB | ✅ |
| (Load Command) LC_SEGMENT_64 | ✅ |
| (Load Command) LC_UUID | ✅ |
| (Load Command) LC_RPATH | ✅ |
| (Load Command) LC_CODE_SIGNATURE | ✅ |
| (Load Command) LC_REEXPORT_DYLIB | ✅ |
| (Load Command) LC_LAZY_LOAD_DYLIB | ✅ |
| (Load Command) LC_ENCRYPTION_INFO | ✅ |
| (Load Command) LC_DYLD_INFO | ✅ |
| (Load Command) LC_DYLD_INFO_ONLY | ✅ |
| (Load Command) LC_LOAD_UPWARD_DYLIB | ✅ |
| (Load Command) LC_VERSION_MIN_MACOSX | ✅ |
| (Load Command) LC_VERSION_MIN_IPHONEOS | ✅ |
| (Load Command) LC_FUNCTION_STARTS | ✅ |
| (Load Command) LC_DYLD_ENVIRONMENT | ✅ |
| (Load Command) LC_MAIN | ✅ |
| (Load Command) LC_DATA_IN_CODE | ✅ |
| (Load Command) LC_SOURCE_VERSION | ✅ |
| (Load Command) LC_DYLIB_CODE_SIGN_DRS | ❌ |
| (Load Command) LC_ENCRYPTION_INFO_64 | ✅ |
| (Load Command) LC_LINKER_OPTION | ✅ |
| (Load Command) LC_LINKER_OPTIMIZATION_HINT | ❌ |
| (Load Command) LC_BUILD_VERSION | ✅ |
| (Load Command) LC_DYLD_EXPORTS_TRIE | ✅ |
| (Load Command) LC_DYLD_CHAINED_FIXUPS | 🌀 |
| (Load Command) LC_FILESET_ENTRY | 🌀 |

|  Macho Component   | Supported  |
|  ----  | ----  |
| (Section Name) \_\_TEXT,\_\_swift5_types  | ✅ 🛠 
| (Section Name) \_\_TEXT,\_\_swift5_reflstr  | ✅ |
| (Section Name) \_\_TEXT,\_\_ustring  | ✅ |
| (Section Name) \_\_TEXT,\_\_text  | ✅ |
| (Section Name) \_\_TEXT,\_\_stubs  | ✅ |
| (Section Name) \_\_TEXT,\_\_stub_helper  | ✅ |
| (Section Name) \_\_TEXT,\_\_objc_methname  | ✅ |
| (Section Name) \_\_TEXT,\_\_cstring  | ✅ |
| (Section Name) \_\_TEXT,\_\_objc_classname  | ✅ |
| (Section Name) \_\_TEXT,\_\_objc_methtype  | ✅ |
|||
| (Section Name) \_\_DATA,\_\_objc_got  | ✅ |
| (Section Name) \_\_DATA,\_\_cfstring | ✅ |
| (Section Name) \_\_DATA,\_\_classlist | ✅ |
| (Section Name) \_\_DATA,\_\_nlclslist | ✅ |
| (Section Name) \_\_DATA,\_\_catlist | ✅ |
| (Section Name) \_\_DATA,\_\_classrefs | ✅ |
| (Section Name) \_\_DATA,\_\_objc_superrefs | ✅ |

|  Macho Component   | Supported  |
|  ----  | ----  |
| (LinkedIt Section) Rebase Info  | 🌀 |
| (LinkedIt Section) Binding Info  | 🌀 |
| (LinkedIt Section) Weak Binding Info  | 🌀 |
| (LinkedIt Section) Lazy Binding Info  | 🌀 |
| (LinkedIt Section) Export Info  | 🌀 |
| (LinkedIt Section) String Table  | ✅ |
| (LinkedIt Section) Symbol Table  | ✅ 🛠|
| (LinkedIt Section) Indirect Symbol Table  | ✅ 🛠 |
| Code Signature  | 🌀 |

---

### Thanks
 
 * MachOView：`MachOView` 是一个 `Mach-O` 文件查看器，是所有 `iOS` 开发者的“必备”工具。但它现在已被弃用。但是里面代码给我提供了很大的帮助
 * WBBlades：`WBBlades` 是基于 `Mach-O` 文件解析的工具集，包括无用代码检测（支持`OC`和`Swift`）、包大小分析（支持单个静态库/动态库的包大小分析）、点对点崩溃解析（基于系统日志，支持有符号状态和无符号状态）
 * [SwiftDump](https://github.com/neil-wu/SwiftDump) : `SwiftDump` 是从 `Mach-O` 文件中获取 `swift` 对象定义的命令行工具
 * [Machismo](https://github.com/g-Off/Machismo) : 使用swift来读取Mach-O文件
 * [Swift metadata](https://knight.sc/reverse%20engineering/2019/07/17/swift-metadata.html) : High level description of all the Swift 5 sections that can show up in a Swift binary.
 * [capstone](https://github.com/aquynh/capstone)
