//
//  MachoViewItem.swift
//  MachoToolGUI
//
//  Created by karthrine on 2022/8/9.
//

import SwiftUI
import MachOTool

struct MachoModuleView: View {
     
    @ObservedObject var cellModel: MachoViewCellModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(cellModel.machoModule.moduleTitle)
                    .foregroundColor(cellModel.isSelected ? .white : .black)
                    .font(.system(size: 13).bold())
                    .padding(.bottom, 2)
                Text(cellModel.machoModule.moduleSubTitle)
                    .foregroundColor(cellModel.isSelected ? .white : .black)
                    .font(.system(size: 12))
                    .padding(.bottom, 2)
                
                if let extraTitle = cellModel.machoModule.moduleExtraTitle {
                    Text(extraTitle)
                        .foregroundColor(cellModel.isSelected ? .white : .black)
                        .font(.system(size: 12))
                        .padding(.bottom, 2)
                }
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
        .background {
            RoundedRectangle(cornerRadius: 4, style: .continuous).fill(cellModel.isSelected ? Theme.selected : .white)
        }
        .contentShape(Rectangle())
        .frame(width: 200)
    }
}
