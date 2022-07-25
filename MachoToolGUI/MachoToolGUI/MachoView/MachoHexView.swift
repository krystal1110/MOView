//
//  MachoView.swift
//  MachoToolGUI
//
//  Created by karthrine on 2022/7/20.
//

import SwiftUI
import MachOTool

struct MachoHexView: View {
    
    var modelList:[ExplanationItem]
    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical, showsIndicators: true)  {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        if modelList.count != 0 {
                            ForEach(0..<modelList.count) { index in
                                if index < modelList.count{
                                    HexLineView(item: modelList[index])
                                }
                            }
                        }
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
    
    init(_ modelList:[ExplanationItem]){
        self.modelList = modelList
    }
    
}



struct HexLineView: View {
    
    var title:String
    var content:String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .fixedSize()
                .padding(.leading, 0)
            Text(content)
                .font(.system(size: 12).monospaced())
                .textSelection(.enabled)
                .fixedSize()
                .padding(.leading, 0)
                 
        }.padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 10))
        
    }
    
    init(item:ExplanationItem){
        self.title = item.model.description ?? ""
        self.content =  item.model.explanation
    }
    
}
