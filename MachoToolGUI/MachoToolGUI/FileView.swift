//
//  FileView.swift
//  MachoToolGUI
//
//  Created by karthrine on 2022/7/14.
//

import SwiftUI
import MachOTool



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
                Text("Arch: \(arch)")
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

    init(_ macho: Macho, isSelected: Bool) {

        self.fileName = "macho.machoFileName"
        self.fileSize = 1000
        self.arch = "macho.header.cpuType.name"
        self.isSelected = isSelected
    }
}

struct FileView: View {

//    let file: File
    @State var selectedIndex: Int


    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
//                    ForEach(0..<file.machos.count) { index in
//                        FileViewCell(file.machos[index], isSelected: index == self.selectedIndex) .onTapGesture {
//                            self.selectedIndex = index
//
//                        }
//                    }
                }
            }
            .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
            .fixedSize(horizontal: true, vertical: false)
            Divider()

        }
    }

    init() {
         
//        self.file = file
        _selectedIndex = State(initialValue: 0)
    }
}




struct Theme {
    static let selected = Color(red: 50/255, green: 130/255, blue: 247/255)
}
