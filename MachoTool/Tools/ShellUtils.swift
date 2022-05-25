//
//  ShellUtils.swift
//  MachoTool
//
//  Created by CoderStar on 2022/5/26.
//

import Foundation

struct ShellUtils {
    /// 执行shell命令
    /// - Parameter command: 命令
    /// - Returns: isSuccess: 命令是否执行成功；result：命令输出结果
    @discardableResult
    static func runShellAndOutput(_ command: String) -> (isSuccess: Bool, result: String?) {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let result = String(data: data, encoding: .utf8)

        task.waitUntilExit()

        return (task.terminationStatus == 0, result)
    }

    /// 执行shell命令
    /// - Parameter command: 命令
    /// - Returns: 是否成功
    @discardableResult
    static func runShell(_ command: String) -> Bool {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus == 0
    }


}
