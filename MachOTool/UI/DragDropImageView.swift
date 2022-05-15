//
//  DragDropImageView.swift
//  MachOTool
//
//  Created by karthrine on 2022/5/4.
//

import Foundation
import Cocoa

class DragDropImageView:NSImageView {
    
 
 
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
//    override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
        
        
    func setUp() {
        self.image = NSImage(named: "file_cad")
        
        self.wantsLayer = true;

        self.layer?.borderColor = NSColor.lightGray.cgColor;
        self.layer?.borderWidth = 2.0;
 
    }
    
    /***
     第二步：当拖动数据进入view时会触发这个函数，返回值不同会显示不同的图标
     ***/
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        let pboard = sender.draggingPasteboard
        
        if ((pboard.types?.contains(.URL)) != nil){
            return .copy
        }
        return .link
    }
    
    
    
    /***
     第三步：当在view中松开鼠标键时会触发以下函数
     ***/
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard
        var fileURL:String = "";
        guard let x = pboard.pasteboardItems else{
            return false;
        }
        
        if (x.count <= 1){
            //获取文件路径
            fileURL = (NSURL.init(from: pboard)?.path )!
        }
        
//        var data = JYFileMananger.readArm64(fromFile: fileURL  as String)
         
//        fileURL    Foundation.URL    "/Users/karthrine/Documents/iOSToolsTest"
        File(fileURL:URL(string: "file:///Users/karthrine/Documents/iOSToolsTest")!)
//        print("url 地址为 \(fileURL)")
        return true
        
    }
 
}

