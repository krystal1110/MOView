//
//  FileView.swift
//  MachoToolGUI
//
//  Created by karthrine on 2022/7/14.
//

import SwiftUI
import MachOTool
import Cocoa



struct FileViewCell: View {

    let fileName: String
    let arch: String
    let fileSize: Int
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(fileName)
                    .lineLimit(1)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .white : .black)
                Text("\(arch)")
                    .lineLimit(1)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .white : .secondary)
                Text("fileSize.hex")
                    .lineLimit(1)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .white : .secondary)
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
        .background{
            RoundedRectangle(cornerRadius: 4, style: .continuous).fill(isSelected ? Theme.selected : .white)
        }
        .contentShape(Rectangle())
    }

    init(_ loadCommand: MachOLoadCommandType, isSelected: Bool) {

        print("---")
        self.fileName = "Load Command"
        self.fileSize = 1000
        self.arch = loadCommand.name
        self.isSelected = isSelected
    }
}

struct FileView: View {

    let fileUrl: URL
    @State var selectedIndex: Int
    var macho:Macho? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    
                    
                    ForEach(0..<self.macho!.commands.count){ index in
                        FileViewCell(self.macho!.commands[index], isSelected: index == self.selectedIndex) .onTapGesture {
                                self.selectedIndex = index
                        }
                    }
                    
                    
//                    ForEach(0..<10) { index in
//                        FileViewCell(file.machos[index], isSelected: index == self.selectedIndex) .onTapGesture {
//                            self.selectedIndex = index
//                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
            .fixedSize(horizontal: true, vertical: false)
            .frame(width: 100, height: 300, alignment: .leading)
            Divider()
            
        }
//    }

    init(fileUrl:URL) {
        self.fileUrl = fileUrl
        _selectedIndex = State(initialValue: 0)
        if let macho = MachoTool.parseMacho(fileURL: fileUrl){
            self.macho = macho
        }
        
    }
}




struct Theme {
    static let selected = Color(red: 50/255, green: 130/255, blue: 247/255)
}
