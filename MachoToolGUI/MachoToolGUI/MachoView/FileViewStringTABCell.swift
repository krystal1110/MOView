//
//  FileViewStringTABCell.swift
//  MachoToolGUI
//
//  Created by karthrine on 2022/7/27.
//

import SwiftUI
import MachOTool

struct FileViewStringTABCell: View{
    
    let compont: ComponentInfo
    
    let isSelected: Bool
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(compont.componentTitle ?? "")
                    .lineLimit(1)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .white : .black)
                Text(compont.componentSubTitle ?? "")
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
    init(_ compont:ComponentInfo, isSelected: Bool){
        self.compont = compont
 
        self.isSelected = isSelected
    }
}
