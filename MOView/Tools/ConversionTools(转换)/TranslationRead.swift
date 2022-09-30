//
//  TranslationRead.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/8.
//

import Foundation





struct DisplayStore{
    let dataSlice: Data
    var title: String = ""
    var subTitle: String = ""
    var extra: String = ""
    var displayItems : [[ExplanationItem]] = []
    
    mutating func insert(section:[ExplanationItem]) {
        self.displayItems.append(section)
    }
    
    mutating func insert(translate:Translate) {
        self.displayItems.append(translate.translateItem)
    }
    
}


class Translate{
    let dataSlice: Data
    var translateItem: [ExplanationItem] = []
    
    /// 提供转换功能
    @discardableResult
    func translate<T>(from:Int, length:Int, dataInterpreter: (Data) -> T, itemContentGenerator: (T) -> ExplanationModel) -> T {
        
        let rawData = DataTool.interception(with: dataSlice, from: from, length: length)
        
        let rawDataAbsoluteRange = dataSlice.startIndex + from ..<  dataSlice.startIndex + from + length
        
        let interpreted: T = dataInterpreter(rawData)
        
        self.translateItem.append(ExplanationItem(sourceDataRange: rawDataAbsoluteRange, model: itemContentGenerator(interpreted)))
        
        return interpreted
    }
    
    init(dataSlice: Data) {
        self.dataSlice = dataSlice
    }
    
    func insert(item:ExplanationItem){
         self.translateItem.append(item)
    }
    
}





// 如果需要显示 则需要存储数据
//public class DisplayStore{
//
////    public var items: [ExplanationItem] = []
//    public let dataSlice: Data
//    public var commandType:String = ""
//    public var segmentName:String = ""
//    public var commandSize:String = ""
//    private var displayItems : [[ExplanationItem]] = []
//
//
//
//    init(dataSlice: Data) {
//        self.dataSlice = dataSlice
//    }
//
//
//    /// 提供转换功能
//    func translate<T>(from:Int, length:Int, dataInterpreter: (Data) -> T, itemContentGenerator: (T) -> ExplanationModel) -> T {
//
//        let rawData = DataTool.interception(with: dataSlice, from: from, length: length)
//
//        let rawDataAbsoluteRange = dataSlice.startIndex + from ..<  dataSlice.startIndex + from + length
//
//        let interpreted: T = dataInterpreter(rawData)
//
////        self.items.append(ExplanationItem(sourceDataRange: rawDataAbsoluteRange, model: itemContentGenerator(interpreted)))
//
//        return interpreted
//    }
//
////    func insert(item:ExplanationItem){
////        self.items.append(item)
////    }
//
//    func insert(section:[ExplanationItem]) {
//        self.displayItems.append(section)
//    }
//
//}


 

struct JYDataTranslationRead {
    static func UInt32(_ data: Data) -> Swift.UInt32 {
        return data.UInt32
    }
}
