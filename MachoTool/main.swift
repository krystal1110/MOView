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

// 基类
class Animal {
    func sleep() {
        print("Animal - sleep")
    }
}

// 子类继承父类
class Dog: Animal {
    // 重写父类的speak，see函数
    override func sleep() {
        print("Dog - Speak")
    }
}

var xxx: Animal = Dog()

xxx.sleep()
