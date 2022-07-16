//
//  MachoTool.swift
//  MachOTool
//
//  Created by karthrine on 2022/7/15.
//

import Foundation


public class MachoTool {
     
    
    public class func parseMacho(fileURL:URL) -> Macho?{
        
        do {
           let file =  try File(fileURL: fileURL)
           let macho = file.machos.first!
           return macho
        } catch {
            print("Whoops! An error occurred: \(error)")
            return nil
        }
        
    }
     
   
    
    
    func scanUselessClasses(){
        
    }
    
    
    
}
