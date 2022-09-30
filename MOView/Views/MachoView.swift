//
//  MachoView.swift
//  MachoToolGUI
//
//  Created by karthrine on 2022/8/9.
//

import SwiftUI


class MachoViewCellModel: ObservableObject, Identifiable {
    let id = UUID()
    var machoModule: MachoModule
    @Published var isSelected: Bool = false
    init(_ c: MachoModule) { self.machoModule = c }
}

struct MachoView: View {
    
    @Binding var macho: Macho
    
    @State var cellModels: [MachoViewCellModel]
    @State var selectedCellModel: MachoViewCellModel?
    var body: some View {
        HStack(spacing:0){
            ScrollView{
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(cellModels){ cellModel in
                        MachoModuleView(cellModel: cellModel)
                            .onTapGesture {
                                if self.selectedCellModel?.machoModule == cellModel.machoModule {return}
                                cellModel.isSelected.toggle()
                                self.selectedCellModel?.isSelected.toggle()
                                self.selectedCellModel = cellModel
                            }
                    }
                }.padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
            }.fixedSize(horizontal: true, vertical: false)
            Divider()
            
            VStack(alignment: .leading) {
                HStack(alignment: .top, spacing: 0) {
                    ParseView(module: selectedCellModel!.machoModule)
                }
                .padding(EdgeInsets(top: 0, leading: 4, bottom: 4, trailing: 4))
            }
        }
    }
    
    
    init(_ macho: Binding<Macho>) {
        _macho = macho
        let machoUnwrapp = macho.wrappedValue
        self.cellModels = machoUnwrapp.modules.map { MachoViewCellModel.init($0) }

        let cellModels = machoUnwrapp.modules.map { MachoViewCellModel.init($0) }
        cellModels.first?.isSelected = true
        _cellModels = State(initialValue: cellModels)
        _selectedCellModel = State(initialValue: cellModels.first)
    }
    
}

 
