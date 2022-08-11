//
//  MachoCellModel.swift
//  MachOTool
//
//  Created by karthrine on 2022/8/9.
//

import Foundation
import Cocoa



public protocol Reveal {
    func numberOfExplanationItemsSections() -> Int
    func numberOfExplanationItems(at section: Int) -> Int
    func cellForExplanationItem(at section: Int, row : Int)  -> ExplanationItem
}



public class MachoModule:Reveal,Equatable {
    let id = UUID()
    public static func == (lhs: MachoModule, rhs: MachoModule) -> Bool {
        return lhs.id == rhs.id
    }
    // 用于标记懒加载过了 不要重复加载
    public var lazyIdentifier = [Int:Bool]()
    public let dataSlice:Data
    public var moduleTitle:String = ""
    public var moduleSubTitle:String = ""
    public var moduleExtraTitle:String?
    // 存储数据的数组 二维数组
    public var translateItems: [[ExplanationItem]]
    
    init(with dataSlice:Data, translateItems: [[ExplanationItem]],moduleTitle:String = "", moduleSubTitle:String = "", moduleExtraTitle:String? = nil){
        self.dataSlice = dataSlice
        self.translateItems = translateItems
        self.moduleTitle = moduleTitle
        self.moduleSubTitle = moduleSubTitle
        self.moduleExtraTitle = moduleExtraTitle
    }
    
    public func numberOfExplanationItemsSections() -> Int {
        return self.translateItems.count
    }
    
    public func numberOfExplanationItems(at section: Int) -> Int {
        return self.translateItems[section].count
    }
    
    public func cellForExplanationItem(at section: Int, row : Int) -> ExplanationItem{
        return self.translateItems[section][row]
    }
    /// 需要保证在 cellForExplanationItem 之前使用
    public func lazyConvertExplanation(at section:Int) {}
    
 
    
}
