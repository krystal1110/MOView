//
//  ContentView.swift
//  MachoToolGUI
//
//  Created by CoderStar on 2022/7/14.
//

import SwiftUI
import MachOTool
import UniformTypeIdentifiers
import Foundation

class OpenPanelDelegate: NSObject, NSOpenSavePanelDelegate {
    func panel(_ sender: Any, shouldEnable url: URL) -> Bool {

        if let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey, .isRegularFileKey]) {
            if let isDirectory = resourceValues.isDirectory,
                isDirectory {
                return true
            }
            
            if let isRegularFile = resourceValues.isRegularFile,
                !isRegularFile {
                return true
            }
        }
        
        let fileHandle = FileHandle(forReadingAtPath: url.path)
        

        if let magicData = try? fileHandle?.read(upToCount: 8),
            let _ = MagicType(magicData) {
            return true
        }
        
        return true
    }
}

 
struct ContentView: View {
    
    @State private var fileURL: URL?
    let openPanelDelegate = OpenPanelDelegate()
    
    var body: some View {
        if let url = fileURL {
            FileView(fileUrl:url)
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
            }.frame(width: 500, height: 300, alignment: .center)
        }
    }
    
}



 
