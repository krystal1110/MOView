//
//  Consts.swift
//  MachoTool
//
//  Created by karthrine on 2022/6/17.
//

import Foundation

enum ESegment: String {
    case TEXT = "__TEXT"
    case DATA = "__DATA"
    case DATA_CONST = "__DATA_CONST"
    
}


enum ESection: String {
    case swift5types     = "__swift5_types"
    case swift5proto    = "__swift5_proto"
    case swift5protos    = "__swift5_protos"
    case swift5filemd   = "__swift5_fieldmd"
    case objc_classlist    = "__objc_classlist"

}
