//
//  LoadCommandsView.swift
//  MachoToolGUI
//
//  Created by karthrine on 2022/7/18.
//

import SwiftUI
//ForEach(0..<self.macho!.commands.count){ index in
//    FileViewCell(self.macho!.commands[index], isSelected: index == self.selectedIndex) .onTapGesture {
//        self.selectedIndex = index
//    }
//}

//struct LoadCommandsCell: View {
//
//    let fileName: String
//    let arch: String
//    let fileSize: Int
//    let isSelected: Bool
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text(fileName)
//                    .lineLimit(1)
//                    .font(.system(size: 14))
//                    .foregroundColor(isSelected ? .white : .black)
//                Text("\(arch)")
//                    .lineLimit(1)
//                    .font(.system(size: 12))
//                    .foregroundColor(isSelected ? .white : .secondary)
//                Text("fileSize.hex")
//                    .lineLimit(1)
//                    .font(.system(size: 12))
//                    .foregroundColor(isSelected ? .white : .secondary)
//            }
//            Spacer()
//        }
//        .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
//        .background{
//            RoundedRectangle(cornerRadius: 4, style: .continuous).fill(isSelected ? Theme.selected : .white)
//        }
//        .contentShape(Rectangle())
//    }
//
//    init(_ loadCommand: MachOLoadCommandType, isSelected: Bool) {
//
//        print("---")
//        self.fileName = "Load Command"
//        self.fileSize = 1000
//        self.arch = loadCommand.name
//        self.isSelected = isSelected
//    }
//}
