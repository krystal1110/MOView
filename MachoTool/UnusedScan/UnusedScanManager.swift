//
//  UnusedScanManager.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/2.
//

import Foundation

//
//class UnusedScanManager {
//
//    var macho:Macho
//
//    init(with macho:Macho) {
//        self.macho = macho
//
//        var allPointerList  : [ReferencesPointer] = []
//        var refsPointerList : [ReferencesPointer] = []
//        var swiftTypesList  : [SwiftNominalModel] = []
//
////        for baseStoreInfo in self.macho.allBaseStoreInfoList {
////            if (baseStoreInfo.componentSubTitle == "__DATA,__objc_classlist") {
////                // 所有的类
////                let storeInfo = baseStoreInfo as! ReferencesStoreInfo
////                allPointerList =  storeInfo.referencesPointerList
////            }else if (baseStoreInfo.componentSubTitle == "__DATA,__objc_classrefs"){
////                // 引用的类
////                let storeInfo = baseStoreInfo as! ClassRefsStoreInfo
////                refsPointerList.append(contentsOf: storeInfo.classRefsPointerList.filter{$0.pointerValue > 0})
////            }else if(baseStoreInfo.componentSubTitle == "__DATA,__objc_nlclslist"){
////                // class +load方法
////                let storeInfo = baseStoreInfo as! ReferencesStoreInfo
////                refsPointerList.append(contentsOf: storeInfo.referencesPointerList)
////            }else if (baseStoreInfo.componentSubTitle == "__DATA,__objc_catlist"){
////                // category
////                let storeInfo = baseStoreInfo as! ReferencesStoreInfo
////                refsPointerList.append(contentsOf: storeInfo.referencesPointerList)
////            }else if (baseStoreInfo.componentSubTitle == "__DATA,__objc_nlcatlist"){
////                // category 的+load方法
////                let storeInfo = baseStoreInfo as! ReferencesStoreInfo
////                refsPointerList.append(contentsOf: storeInfo.referencesPointerList)
////            }else if (baseStoreInfo.componentSubTitle == "__TEXT,__swift5_types"){
////                // 存储swiftTypes5
//////                let storeInfo = baseStoreInfo as! SwiftTypesStoreInfo
//////                swiftTypesList = storeInfo.swiftTypesObjList
////            }
//
//
////            self.macho.symbolTableStoreInfo?.symbolTableList.sorted(by: { $0.nValue > $1.nValue})
////
////
////            for nominalModel in swiftTypesList {
////
////
////
////
////                for (i,symObj) in self.macho.symbolTableStoreInfo!.symbolTableList.enumerated() {
////
////                    var startValue: UInt64 = 0;
////                    var endValue: UInt64 = 0;
////                    if (i == ( self.macho.symbolTableStoreInfo!.symbolTableList.count - 1 ) ) {
////                        // 最后一个了
////                        //                     startValue =  symObj.nValue
////                        //                    let endValue = symObj.nValue + symObj.
////                    }else {
////                        startValue =  symObj.nValue
////                        endValue = self.macho.symbolTableStoreInfo!.symbolTableList[i + 1].nValue
////                    }
////
////                    findCallAccessFunc(nominalModel.typeName, accessFunc: nominalModel.accessorOffset, startVale: startValue, endValue: 4295100480)
////                }
////
////            }
////
////
////        }
////        unusedFilter(allPointerList, fiterPointer: refsPointerList)
//    }
//
//
//
//
//
//
//
//
//
//
//
//    func findCallAccessFunc(_ typeName: String, accessFunc: UInt64 , startVale: UInt64, endValue: UInt64) {
//
//        let targetStr = String(format: "0x%llX",  accessFunc).localizedLowercase
//        let targetHighStr = String(format: "0x%llX",  accessFunc & 0xFFFFFFFFFFFFF000).localizedLowercase
//        let targetLowStr = String(format: "0x%llX",  accessFunc & 0x0000000000000fff).localizedLowercase
//        let result = scanSELCallerWithAddress(targetStr: targetStr, targetHighStr: targetHighStr, targetLowStr: targetLowStr, begin: startVale, end: endValue)
//        if result {
////            print("----")
//        }
//
//    }
//
//
//
//
//
//    /*
//     扫描函数代码中是否包含有 AccessFunc 的地址，如果有则代表有用到这个类，如果没有则代表没有用到
//     注意：会有一种特殊情况为 Swift访问并不是通过AccessFunc，而是直接访问类的地址，这种情况一般会在符号表中存在demangling cache variable for type metadata for开头的符号
//     begin 代表符号地址开始
//     end   代表符号地址结束
//     **/
//    func scanSELCallerWithAddress(targetStr: String, targetHighStr: String, targetLowStr: String, begin: UInt64, end: UInt64) -> Bool {
//
//        var textAddr:UInt64 = 4294983680
//
//        var endAddr:UInt64 = 0
//
//        var asmStr:String = ""
//        var high = false
//        if (begin <  textAddr ){
//            return false
//        }
//
//        let maxText = textAddr + 125456
//
//        endAddr = min(maxText, end)
//
//        var beginAddr = begin
//        while (strcmp("ret",asmStr) != 0 && (beginAddr < end)){
//
//            let index = (beginAddr - textAddr) / 4
//            let dataStr =  Utils.readCharToString(&self.macho.instructionPtr![Int(index)].op_str)
//            asmStr =  Utils.readCharToString(&self.macho.instructionPtr![Int(index)].mnemonic)
//
//            if (strcmp(".byte", asmStr) == 0){
//                return false
//            }
//
//            if (Utils.strStr(dataStr, targetStr)){
//                // 直接命中
//                print("我命中了 \(dataStr) 与 \(targetStr)  index = \(index)")
//                return true
//            }else if (Utils.strStr(dataStr, targetHighStr) && Utils.strStr(asmStr, "adrp")){
//                // 命中高位
//                high = true
//            }else if (Utils.strStr(dataStr, targetLowStr)) {
//                // 命中低12位
//                if high { return true }
//            }
//            // 4个字节4个字节读取
//            beginAddr += 4
//        }
//        return false
//    }
//
//
//
//
//
//
//
//
//
//
//
//    func unusedFilter(_ allPointer:[ReferencesPointer], fiterPointer:[ReferencesPointer]){
//
//        //        var refsIndexList:[UInt64] = []
//        let result = allPointer.filter {  !fiterPointer.compactMap{$0.pointerValue}.contains($0.pointerValue)}
//
//        result.map{print($0.explanationItem?.model.extraExplanation)}
//
//    }
//}
//
//
//
//
//
//
//
//
