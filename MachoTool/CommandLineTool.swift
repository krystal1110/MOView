//
//  CommandLineTool.swift
//  MachoTool
//
//  Created by karthrine on 2022/5/16.
//

import Foundation
 
public final class CommandLineTool {
    private let arguments: [String]
 
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
 
    public func run() throws {
        let str = "file:///Users/karthrine/Documents/MachoTool/MachoTool/iOSToolsTest"
        File(fileURL: URL(string:str)!)
    }
    
 
}

 

@discardableResult
func runShell(_ command: String) -> Int32 {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

@discardableResult
func runShellWithArgs(_ args: String...) -> Int32 {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}
