//
//  ContentView.swift
//  MachoToolGUI
//
//  Created by CoderStar on 2022/7/14.
//

import SwiftUI
import MachOTool
import UniformTypeIdentifiers

//    let tool = CommandLineTool()
//
//    do {
//        try tool.run()
//    } catch {
//        print("Whoops! An error occurred: \(error)")
//    }




struct ContentView: View {
    
    @State private var fileURL: URL?
    let openPanelDelegate = OpenPanelDelegate()
    
    var body: some View {
        if let fileURL = fileURL {
            //            FileView(file: File(with: fileURL)).navigationTitle(fileURL.absoluteString)
        } else {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button("Select File") {
                        let openPanel = NSOpenPanel()
                        openPanel.treatsFilePackagesAsDirectories = true
                        openPanel.allowsMultipleSelection = false
                        openPanel.canChooseDirectories = false
                        openPanel.canCreateDirectories = false
                        openPanel.canChooseFiles = true
                        openPanel.delegate = self.openPanelDelegate
                        openPanel.begin {
                            if $0 == .OK {
                                self.fileURL = openPanel.url
                            }
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
        }
    }
    
}



class OpenPanelDelegate: NSObject, NSOpenSavePanelDelegate {
    func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
        
        if let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey, .isRegularFileKey]) {
            if let isDirectory = resourceValues.isDirectory,
                isDirectory {
                return true
            }
            
            if let isRegularFile = resourceValues.isRegularFile,
                !isRegularFile {
                return false
            }
        }
        
        let fileHandle = FileHandle(forReadingAtPath: url.path)
        if let magicData = try? fileHandle?.read(upToCount: 8){
            return true
        }
        
        return false
    }
}
