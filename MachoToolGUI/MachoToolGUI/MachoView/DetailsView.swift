//
//  DetailsView.swift
//  MachoToolGUI
//
//  Created by karthrine on 2022/7/28.
//

import SwiftUI
import MachOTool
 

 
struct DetailsView: View {
    
//    var item:[ExplanationItem]
    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical, showsIndicators: true)  {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        Text("详细数据")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .fixedSize()
                            .padding(.leading, 0)
                        Text("range ")
                            .font(.system(size: 12).monospaced())
                            .textSelection(.enabled)
                            .fixedSize()
                            .padding(.leading, 0)
                        VStack(){
                            Divider().background(Color.gray)
                                .scaleEffect(CGSize(width: 1, height: 1))
                        }
                    }
                }
                
            }
        }
        .padding(4)
        .border(.separator, width: 1)
        .background(.white)
    }
    
    init(){
//        self.modelList = modelList
    }
    
}
