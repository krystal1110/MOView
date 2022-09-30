//
//  MachoCellModel.swift
//  MachOTool
//
//  Created by karthrine on 2022/8/9.
//

import Foundation
import Cocoa



protocol DisplayProtocol {
    func numberOfExplanationItemsSections() -> Int
    func numberOfExplanationItems(at section: Int) -> Int
    func cellForExplanationItem(at section: Int, row : Int)  -> ExplanationItem
}



  class MachoModule:DisplayProtocol,Equatable {
    let id = UUID()
      static func == (lhs: MachoModule, rhs: MachoModule) -> Bool {
        return lhs.id == rhs.id
    }
    // 用于标记懒加载过了 不要重复加载
      var lazyIdentifier = [Int:Bool]()
      let dataSlice:Data
      var moduleTitle:String = ""
      var moduleSubTitle:String = ""
      var moduleExtraTitle:String?
    // 存储数据的数组 二维数组
      var translateItems: [[ExplanationItem]]
    
    init(with dataSlice:Data, translateItems: [[ExplanationItem]],moduleTitle:String = "", moduleSubTitle:String = "", moduleExtraTitle:String? = nil){
        self.dataSlice = dataSlice
        self.translateItems = translateItems
        self.moduleTitle = moduleTitle
        self.moduleSubTitle = moduleSubTitle
        self.moduleExtraTitle = moduleExtraTitle
    }
    
      func numberOfExplanationItemsSections() -> Int {
        return self.translateItems.count
    }
    
      func numberOfExplanationItems(at section: Int) -> Int {
        return self.translateItems[section].count
    }
    
      func cellForExplanationItem(at section: Int, row : Int) -> ExplanationItem{
        return self.translateItems[section][row]
    }
    /// 需要保证在 cellForExplanationItem 之前使用
      func lazyConvertExplanation(at section:Int) {}
    
 
    
}


 
