//
//  GeneralModel.swift
//  MachoToolGUI
//
//  Created by karthrine on 2022/7/18.
//

import Foundation
import MachOTool
import MachO

/// 通用配置model 用于显示
/// 暂时记录的 后面会慢慢修改

public struct GeneralModel {
    public var name:String
    public var value:String
    public var offset:String? = nil
    public var data:String? = nil
    
    init(name :String, value:String, offset:String? = nil, data:String? = nil){
        self.name = name
        self.value = value
        self.offset = offset
        self.data = data
    }
}

public struct ExtraData{
    
}


public struct DisplayModel{
    var sourceDataRange: Range<Int>
    var extraList:ExtraData? = nil
}

 


/// 拼装GUI需要显示的数据
public struct Display {
    
    public static func machoHeaderDisplay(_ machoHeader:MachOHeader) -> [ExplanationItem] {
        return machoHeader.displayStore.items
    }
    
    
    
    public static func loadCommondDisplay(_ loadCommand:MachOLoadCommandType) -> [ExplanationItem] {
        return loadCommand.displayStore.items
    }
 
    public static func loadCompontsDisplay(_ compont:ComponentInfo) -> [ExplanationItem] {
        
        
        let type  = type(of: compont)
        if type == StringComponent.self {
            let item = compont as! StringComponent
            let x = item.stringList.compactMap{$0.explanationItem};
            return x
        }else if type == SymbolTableComponent.self{
            var item = compont as! SymbolTableComponent
            
            let symbolNameItem = item.symbolTableList[0].findSymbolName()
            item.symbolTableList[0].translaitonItems.append(symbolNameItem)
            
            return item.symbolTableList[0].translaitonItems
            
               
        }else if type == TextComponent.self{
            
        }else if type == UnknownCmponent.self{
            
        }
 
        
   
         
        return []
    }
 
    
}




 
