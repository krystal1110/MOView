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
    
    var title: String = ""
    var subTitle: String = ""
    var extraTitle: String = ""
    var isSelected: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .lineLimit(1)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .white : .black)
                Text(subTitle)
                    .lineLimit(1)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .white : .secondary)
                Text(extraTitle)
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
 
    
    init<T>(_ loadCommand: T, isSelected: Bool) {

        
        if let xxx = loadCommand as? MachOLoadCommandType{
            
            self.title = "Load Command"
            self.subTitle = xxx.displayStore.commandType
            self.extraTitle =  xxx.displayStore.commandSize
             
        }else if let xxx = loadCommand as? ComponentInfo{
            self.title = xxx.typeTitle ?? ""
            self.subTitle =   "\(xxx.componentTitle ?? ""),\(xxx.componentSubTitle ?? "")"
            self.extraTitle = ""
        }

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
                Text("\(header.cpuTypeString)")
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
    @State var macho: Macho
    
    var body: some View {
        VStack(spacing:0){
            MachoView($macho)
        }.padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 10))
    }
    
    init(fileUrl:URL) {
        self.fileUrl = fileUrl
        let macho = MachoTool.parseMacho(fileURL: fileUrl)
        _macho = State(initialValue: macho!)
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


 
