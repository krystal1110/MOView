//
//  ViewController.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/4.
//

import Cocoa

class ViewController: NSViewController {
    
    
    @IBOutlet weak var loadMachOView: DragDropImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        self.loadMachOImageView
        
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func deadCodeAnalysis(_ sender: Any) {
    // 无用代码检测
        File(fileURL:URL(string: "file:///Users/karthrine/Documents/iOSToolsTest")!)
        
    }
 
    
    func shell(_ url:URL){
    do {
        // 这里的 URL 是 shell 脚本的路径
        let task = try NSUserAppleScriptTask.init(url: url)
        task.execute(withAppleEvent: nil) { (result, error) in
            var message = result?.stringValue ?? ""
            // error.debugDescription 也是执行结果的一部分，有时候超时或执行 shell 本身返回错误，而我们又需要打印这些内容的时候，就需要用到它。
            
            message = message.count == 0 ? error.debugDescription : message
        }
    } catch {
        // 执行的相关错误
    }
    }

}

