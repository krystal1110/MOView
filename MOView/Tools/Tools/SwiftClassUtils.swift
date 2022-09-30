//
//  SwiftClassUtils.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/16.
//

import Foundation

class SwiftClassUtils {
 
    class func getSwiftType(_ type:SwiftType) -> SwiftKind {
        //读低五位判断类型
        if ((type.flag & 0x1f) == SwiftKind.SwiftKindClass.rawValue ){
            return .SwiftKindClass
        }else  if ((type.flag & 0x3) == SwiftKind.SwiftKindProtocol.rawValue ){
            return .SwiftKindProtocol;
        }else  if ((type.flag & 0x1f) == SwiftKind.SwiftKindStruct.rawValue ){
            return .SwiftKindProtocol;
        }else  if ((type.flag & 0x1f) == SwiftKind.SwiftKindEnum.rawValue ){
            return .SwiftKindEnum;
        }else  if ((type.flag & 0x1f) == SwiftKind.SwiftKindModule.rawValue ){
            return .SwiftKindModule;
        }else  if ((type.flag & 0x1f) == SwiftKind.SwiftKindAnonymous.rawValue ){
            return .SwiftKindAnonymous;
        }else  if ((type.flag & 0x1f) == SwiftKind.SwiftKindOpaqueType.rawValue ){
            return .SwiftKindOpaqueType;
        }
        
        
        return .SwiftKindUnknown
    }
    
}


enum SwiftKind:Int {
    case SwiftKindUnknown    = -1
    case SwiftKindModule     = 0
    case SwiftKindAnonymous  = 2
    case SwiftKindProtocol   = 3
    case SwiftKindOpaqueType = 4
    case SwiftKindClass      = 16
    case SwiftKindStruct     = 17
    case SwiftKindEnum       = 18
}
 
