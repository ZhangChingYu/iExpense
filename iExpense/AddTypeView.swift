//
//  AddTypeView.swift
//  iExpense
//
//  Created by Sunny on 2024/7/29.
//

import SwiftUI

struct AddTypeView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var newTypeName = ""
    @State private var TypeIcon = "car"
    
    var types: ExpenseTypes
    
    let icons = ["car", "house.fill", "dollarsign.square.fill", "headphones", "gift.fill", "phone", "cart", "creditcard", "wand.and.stars", "bandage.fill", "paintbrush", "map", "music.mic", "airplane", "gamecontroller", "tram.fill", "book", "hand.raised"]
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Enter new type:", text: $newTypeName)
                Picker("Pick an icon", selection: $TypeIcon){
                    ForEach(icons, id: \.self){
                        Image(systemName: $0)
                            .foregroundStyle(.black, .green, .yellow)
                            .frame(width: 30, height: 30)
                    }
                }
                .pickerStyle(.inline)
            }
            .navigationTitle("Add New Type")
            .toolbar {
                Button("Save"){
                    let newType = ExpenseType(name: newTypeName, icon: TypeIcon)
                    types.types.append(newType)
                    dismiss()
                }
            }
        }
        
    }
}

#Preview {
    AddTypeView(types: ExpenseTypes())
}
