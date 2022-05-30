//
//  main.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/16.
//

let tool = CommandLineTool()

do {
    try tool.run()
} catch {
    print("Whoops! An error occurred: \(error)")
}

 
