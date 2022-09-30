//
//  SwiftTypesStoreInfo.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/22.
//

import Foundation

class SwiftTypesModule:MachoModule{
    var accessFuncDic: Dictionary<String,UInt64>
    var swiftRefsSet:Set<String>
    var pointers : [SwiftTypeModel]
    
    init(with dataSlice: Data ,
         section:Section64,
         pointers:[SwiftTypeModel],
         swiftRefsSet:Set<String>,
         accessFuncDic: Dictionary<String,UInt64>) {
        
        self.swiftRefsSet = swiftRefsSet
        self.accessFuncDic = accessFuncDic
        self.pointers = pointers
        
        var translateItems:[[ExplanationItem]]  = []
        for item in pointers{
            var explanationItems:[ExplanationItem] = []
            
            explanationItems.append(ExplanationItem(sourceDataRange: nil, model: ExplanationModel(description: "Class Name", explanation: item.name)))
            
            
            if let superclassName = item.superClass , !superclassName.isEmpty{
                let item =   ExplanationItem(sourceDataRange: nil, model: ExplanationModel(description: "SuperClass", explanation: superclassName))
                explanationItems.append(item)
            }
            
            explanationItems.append(ExplanationItem(sourceDataRange: nil, model: ExplanationModel(description: "NumberOfFields", explanation: "\(item.fields.count)")))
            
            explanationItems.append(ExplanationItem(sourceDataRange: nil, model: ExplanationModel(description: "Access Offset", explanation: item.accessOffset.hex)))
            
            translateItems.append(explanationItems)
        }
        let subTitle = "\(section.segname),\(section.sectname)"
        super.init(with: dataSlice, translateItems: translateItems,moduleTitle: "Section",moduleSubTitle: subTitle)
    }
}
