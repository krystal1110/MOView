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
        let result = ShellUtils.runShellAndOutput("pwd")
        if result.isSuccess, let productPath = result.result {
            var path = productPath.trimmingCharacters(in: CharacterSet(charactersIn: "\n"))
            let unzipResult = ShellUtils.runShell("unzip -o \(path)/iOSToolsTest.zip")
            if unzipResult {
                path = "\(path)/iOSToolsTest"
                _ = File(fileURL: URL(fileURLWithPath: path))
            } else {
                fatalError("unzip error")
            }

        } else {
            fatalError("shell error")
        }
    }
}
