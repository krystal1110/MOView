//
//  ParseView.swift
//  MachoToolGUI
//
//  Created by karthrine on 2022/8/10.
//

import SwiftUI
import MachOTool

class SelectedIndexWrapper: ObservableObject {
    @Published var selectedIndexPath: IndexPath = .init(item: .zero, section: .zero)
}
 



struct ParseView: View {
    
    let module: MachoModule
    let selectIndexWrapper : SelectedIndexWrapper = SelectedIndexWrapper()
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.vertical, showsIndicators: true)  {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(0..<module.numberOfExplanationItemsSections(), id: \.self) { section in
                        self.translationSectionView(at: section)
                    }
                }
                .padding(4)
            }
            .background(.white)
            .border(.separator, width: 1)
            .frame(minWidth: 400)
            .onChange(of: module) { newValue in
                scrollProxy.scrollTo(0, anchor: .top)
            }
        }
    }
    
    func translationSectionView(at section: Int) -> some View {
        let x = ForEach(indexedTranslationItems(at: section), id: \.indexPath) { item in
            VStack(alignment: .leading, spacing: 0) {
                ParseViewItemView(item: item)
            }
        }
        return x
    }
    
    func indexedTranslationItems(at section: Int) -> [IndexedExplanationItem] {

        module.lazyConvertExplanation(at: section)
        
        let numberOfExplanationItems = module.numberOfExplanationItems(at:section)
          
        return (0..<numberOfExplanationItems).map { itemIndex in
            // lazy explanation
             
            let item = module.cellForExplanationItem(at: section, row: itemIndex)
                      
            let indexPath = IndexPath(item: itemIndex, section: section)
           
            if numberOfExplanationItems - 1 == itemIndex{
                 
                return IndexedExplanationItem(item: item, indexPath: indexPath,hasDivider: true)
            }else{
                return IndexedExplanationItem(item: item, indexPath: indexPath,hasDivider: false)
            }
            
             
        }
       
    }
    
    
}

 
 



private struct ParseViewItemView: View {

    let item: IndexedExplanationItem
//    var isSelected: Bool { selectedIndexWrapper.selectedIndexPath == item.indexPath && item.content.explanationStyle.selectable }
    var isSelected: Bool = false
    @EnvironmentObject var selectedIndexWrapper: SelectedIndexWrapper

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            if let description = item.item.model.description {
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 2)
            }
            Text(item.item.model.explanation)
                .foregroundColor(.black)
//                .foregroundColor(isSelected ? .white : item.content.explanationStyle.fontColor)
//                .font(item.item.monoSpaced ? .system(size: 12).monospaced() : .system(size: 14))
                .background(isSelected ? Theme.selected : .white)
            if let extraDescription = item.item.model.extraDescription {
                Text(extraDescription)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
                    .padding(.bottom, 2)
            }
            if let extraExplanation = item.item.model.extraExplanation {
                Text(extraExplanation)
                    .foregroundColor(.black)
                    .font(.system(size: 12))
            }
//            if item.hasDivider {
                Divider().background(.blue)
//            }
        }
        .padding(.leading, 4)
        .padding(.bottom, 3)
        .padding(.top, 3)
    }
}

struct IndexedExplanationItem {
    let item: ExplanationItem
    let indexPath: IndexPath
    var sourceDataRange: Range<Int>? { item.sourceDataRange }
    var hasDivider: Bool
//    var content: TranslationItemContent { item.content }
}

 
