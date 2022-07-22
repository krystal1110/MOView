//
//  FileView.swift
//  MachoToolGUI
//
//  Created by karthrine on 2022/7/14.
//

import SwiftUI
import MachOTool
import Cocoa
import MachO
import Combine



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

struct FileMachoHeaderCell: View{
    
    let header: MachOHeader
    let fileName: String
    let isSelected: Bool
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(fileName)
                    .lineLimit(1)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .white : .black)
                Text("\(header.cpuType)")
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
    init(_ header:MachOHeader, isSelected: Bool){
        self.header = header
        self.fileName = "Macho Header"
        self.isSelected = isSelected
    }
}


struct FileView: View {
    
    let fileUrl: URL
    @State var selectedIndex: Int
    var macho:Macho? = nil
    var body: some View {
        VStack(spacing:0){
            GeometryReader{ px in
                HSplitView{
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            FileMachoHeaderCell(self.macho!.header,isSelected: -1 == self.selectedIndex).onTapGesture{self.selectedIndex = -1}
                            ForEach(0..<self.macho!.commands.count){ index in
                                FileViewCell(self.macho!.commands[index], isSelected: index == self.selectedIndex) .onTapGesture {
                                    self.selectedIndex = index
                                }
                            }
                        }
                    }.frame(minWidth:200,maxWidth: 200)
                    if selectedIndex == -1 {
                        MachoHexView(Display.machoHeaderDisplay(macho!.header))
                            .frame(minWidth:300)
                    }else{
                        MachoHexView(Display.loadCommondDisplay(macho!.commands[selectedIndex]))
                            .frame(minWidth:300)
                    }
                }
            }
        }.padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 10))
    }
    
    init(fileUrl:URL) {
        self.fileUrl = fileUrl
        _selectedIndex = State(initialValue: -1)
        if let macho = MachoTool.parseMacho(fileURL: fileUrl){
            self.macho = macho
        }
    }
}




struct Theme {
    static let selected = Color(red: 50/255, green: 130/255, blue: 247/255)
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
