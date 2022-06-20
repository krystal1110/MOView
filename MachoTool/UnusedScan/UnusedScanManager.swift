//
//  UnusedScanManager.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/2.
//

import Foundation


class UnusedScanManager {
    
    var macho:Macho
    
    init(with macho:Macho) {
        self.macho = macho
        
        var allPointerList  : [ReferencesPointer] = []
        var refsPointerList : [ReferencesPointer] = []
        
        for baseStoreInfo in self.macho.allBaseStoreInfoList {
            if (baseStoreInfo.componentSubTitle == "__DATA,__objc_classlist") {
                // 所有的类
                let storeInfo = baseStoreInfo as! ReferencesStoreInfo
                allPointerList =  storeInfo.referencesPointerList
            }else if (baseStoreInfo.componentSubTitle == "__DATA,__objc_classrefs"){
                // 引用的类
                let storeInfo = baseStoreInfo as! ClassRefsStoreInfo
                refsPointerList.append(contentsOf: storeInfo.classRefsPointerList.filter{$0.pointerValue > 0})
            }else if(baseStoreInfo.componentSubTitle == "__DATA,__objc_nlclslist"){
                // class +load方法
                let storeInfo = baseStoreInfo as! ReferencesStoreInfo
                refsPointerList.append(contentsOf: storeInfo.referencesPointerList)
            }else if (baseStoreInfo.componentSubTitle == "__DATA,__objc_catlist"){
                // category
                let storeInfo = baseStoreInfo as! ReferencesStoreInfo
                refsPointerList.append(contentsOf: storeInfo.referencesPointerList)
            }else if (baseStoreInfo.componentSubTitle == "__DATA,__objc_nlcatlist"){
                // category 的+load方法
                let storeInfo = baseStoreInfo as! ReferencesStoreInfo
                refsPointerList.append(contentsOf: storeInfo.referencesPointerList)
            }
            
            
            
        }
        unusedFilter(allPointerList, fiterPointer: refsPointerList)
    }
    
    func unusedFilter(_ allPointer:[ReferencesPointer], fiterPointer:[ReferencesPointer]){
        
//        var refsIndexList:[UInt64] = []
        let result = allPointer.filter {  !fiterPointer.compactMap{$0.pointerValue}.contains($0.pointerValue)}
        
        result.map{print($0.explanationItem?.model.extraExplanation)}
        print("---")
    }
    
}


