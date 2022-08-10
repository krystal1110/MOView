//
//  MachoViewItem.swift
//  MachoToolGUI
//
//  Created by karthrine on 2022/8/9.
//

import SwiftUI

struct MachoViewItem: View {
    @ObservedObject var item: T

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(cellModel.machoComponent.componentTitle)
                    .font(.system(size: 13).bold())
                    .foregroundColor(cellModel.isSelected ? .white : .black)
                    .padding(.bottom, 2)
                if let primaryName = cellModel.machoComponent.componentSubTitle {
                    Text(primaryName)
                        .font(.system(size: 12))
                        .foregroundColor(cellModel.isSelected ? .white : .black)
                        .padding(.bottom, 2)
                }
//                if let secondaryDescription = cellModel.machoComponent.componentDescription {
//                    Text(secondaryDescription)
//                        .font(.system(size: 12))
//                        .foregroundColor(cellModel.isSelected ? .white : .secondary)
//                        .lineLimit(1)
//                        .padding(.bottom, 2)
//                }
                Text(cellModel.machoComponent.componentRange)
                    .font(.system(size: 12))
                    .foregroundColor(cellModel.isSelected ? .white : .secondary)
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
