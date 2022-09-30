//
//  ParseDyldInfo.swift
//  MachOTool
//
//  Created by karthrine on 2022/8/11.
//

import Foundation

class ParseDyldInfo {
    
//    var textInstructionPtr: UnsafeMutablePointer<cs_insn>?
    
    var modules: [MachoModule] = []
    
    func parseDyldInfo(_ data:Data ,commonds: [MachOLoadCommandType], searchProtocol: SearchProtocol ){
        
        for item in commonds {
            
            if let _ = item as? MachOLoadCommand.LC_DyldInfo{
                
                dyldInfoComponts(wiht:data, command:item, searchProtocol: searchProtocol)
                
            }
            
        }
        print("🔥🔥🔥 解析 __TEXT 完成  🔥🔥🔥")
    }
    
    
    func dyldInfoComponts(wiht data:Data, command:MachOLoadCommandType,searchProtocol: SearchProtocol ){
      
        
        let dyldInfoCommand = command as! MachOLoadCommand.LC_DyldInfo
 
         
        let rebaseInfoStart = Int(dyldInfoCommand.command.rebase_off)
        let rebaseInfoSize = Int(dyldInfoCommand.command.rebase_size)
        if rebaseInfoStart.isNotZero && rebaseInfoSize.isNotZero {
            let rebaseInfoData = DataTool.interception(with: data, from: rebaseInfoStart, length: rebaseInfoSize)
          let interpreter =  OperationCodeInterpreter<RebaseOperationCode>.init(with: data, section: nil, searchProtocol: searchProtocol)
        }
        
        
        let bindInfoStart = Int(dyldInfoCommand.command.bind_off)
        let bindInfoSize = Int(dyldInfoCommand.command.bind_size)
        if bindInfoStart.isNotZero && bindInfoSize.isNotZero {
            let bindInfoData =  DataTool.interception(with: data,from: bindInfoStart, length: bindInfoSize)
            let interpreter =  OperationCodeInterpreter<BindOperationCode>.init(with: data, section: nil, searchProtocol: searchProtocol)
        }
        
        let weakBindInfoStart = Int(dyldInfoCommand.command.weak_bind_off)
        let weakBindSize = Int(dyldInfoCommand.command.weak_bind_size)
        if weakBindInfoStart.isNotZero && weakBindSize.isNotZero {
             
            let weakBindData = DataTool.interception(with: data,from: weakBindInfoStart, length: weakBindSize)
            let interpreter =  OperationCodeInterpreter<BindOperationCode>.init(with: data, section: nil, searchProtocol: searchProtocol)
        }
        
        
        let lazyBindInfoStart = Int(dyldInfoCommand.command.lazy_bind_off)
        let lazyBindSize = Int(dyldInfoCommand.command.lazy_bind_size)
        if lazyBindInfoStart.isNotZero && lazyBindSize.isNotZero {
            let lazyBindData = DataTool.interception(with: data,from: lazyBindInfoStart, length: lazyBindSize)
            let interpreter =  OperationCodeInterpreter<BindOperationCode>.init(with: data, section: nil, searchProtocol: searchProtocol)

        }
        
        
        let exportInfoStart = Int(dyldInfoCommand.command.export_off)
        let exportInfoSize = Int(dyldInfoCommand.command.export_size)
        if exportInfoStart.isNotZero && exportInfoSize.isNotZero {
            let exportInfoData = DataTool.interception(with: data,from: exportInfoStart, length: exportInfoSize)
            let interpreter =  ExportInfoInterpreter.init(with: data, section: nil, searchProtocol: searchProtocol)
            
        }
        

    }

     
}

 
