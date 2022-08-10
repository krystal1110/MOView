//
//  MachoView.swift
//  MachoToolGUI
//
//  Created by karthrine on 2022/8/9.
//

import SwiftUI
import MachOTool

struct MachoView: View {
    
    @Binding var macho: Macho
    
    var body: some View {
        HStack(spacing:0){
            ScrollView{
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(0..<10){_ in
                        Text("Just do it ")
                    }
                }
            }
        }
    }
    
    
    init(_ macho: Binding<Macho>) {
        _macho = macho
        let machoUnwrapp = macho.wrappedValue
        
//        let cellModels = machoUnwrapp.machoComponents.map { MachoViewCellModel.init($0) }
//        cellModels.first?.isSelected = true
//        _cellModels = State(initialValue: cellModels)
//        _selectedCellModel = State(initialValue: cellModels.first)
//
//        _selectedMachoComponent = State(initialValue: machoUnwrapp.machoComponents.first!)
//        let selectedRange = macho.wrappedValue.header.firstTransItem?.sourceDataRange
//        _selectedDataRange = State(initialValue: selectedRange)
//        let hexStore = HexLineStore(macho.wrappedValue.header)
//        hexStore.updateLinesWith(selectedBytesRange: selectedRange)
//        _hexStore = State(initialValue: hexStore)
    }
    
}

 
