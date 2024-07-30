//
//  AddView.swift
//  iExpense
//
//  Created by Sunny on 2024/7/29.
//

import SwiftUI

struct ExpenseType: Identifiable, Codable {
    var id = UUID()
    let name: String
    let icon: String
}

@Observable
class ExpenseTypes {
    var types = [ExpenseType]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(types) {
                UserDefaults.standard.set(encoded, forKey:"Types")
            }
        }
    }
    init() {
        if let saveTypes = UserDefaults.standard.data(forKey: "Types") {
            if let decodedTypes = try? JSONDecoder().decode([ExpenseType].self, from: saveTypes) {
                types = decodedTypes
                return
            }
        }
        types = [
            ExpenseType(name: "Bill", icon: "dollarsign.square.fill"),
            ExpenseType(name: "Food", icon: "cart"),
            ExpenseType(name: "House", icon: "house.fill"),
            ExpenseType(name: "Cloth", icon: "paintbrush"),
            ExpenseType(name: "Shopping", icon: "creditcard"),
            ExpenseType(name: "Communication", icon: "phone"),
            ExpenseType(name: "Transport", icon: "car"),
            ExpenseType(name: "Health", icon: "bandage.fill"),
            ExpenseType(name: "Entertainment", icon: "gamecontroller"),
            ExpenseType(name: "Education", icon: "book")
        ]
    }
}

struct AddView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var selectedType = "Bill"
    @State private var currencyCode = "TWD"
    @State private var amount:Double = 0.0
    
    @State private var showingAddType = false
    @State private var expenseTypes = ExpenseTypes()

    var expenseMap: ExpneseMap
    
    let types = ["Business", "Personal"]
    let currencyCodes = ["USD", "TWD", "AUD", "CNY"]
    let expendTypes = ["Bill", "Clothes", "Food", "Communication", "Eating Out", "Entertainment", "Gifts", "Health", "Transport", "House"]
    
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    HStack {
                        Text("Type")
                        Spacer()
                        Text(selectedType)
                    }
                    HStack {
                        TextField("Amount", value: $amount, format: .number.precision(.fractionLength(2)))
                            .keyboardType(.decimalPad)
                        Spacer()
                        Picker("Currency Code", selection: $currencyCode){
                            ForEach(currencyCodes, id: \.self){
                                Text($0)
                            }
                        }
                        .labelsHidden()
                    }
                    
                }
            }
            .navigationTitle("Add new expense")
            .toolbar {
                Button("Save"){
                    let item = ExpenseItem(name: name, type: selectedType, currencyCode: currencyCode, amount: amount)
                    guard (expenseMap.expenses[selectedType]?.count) != nil else {
                        expenseMap.expenses[selectedType] = []
                        return
                    }
                    expenseMap.expenses[selectedType]?.append(item)
                    dismiss()
                }
            }
            .sheet(isPresented: $showingAddType) {
                AddTypeView(types: expenseTypes)
            }
            Text("Pick A Type")
                .font(.largeTitle)
            ScrollView{
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem(), GridItem()], spacing: 20){
                    ForEach(expenseTypes.types){ type in
                        Button {
                            selectedType = type.name
                        } label: {
                            VStack(spacing: 0) {
                                Image(systemName: type.icon)
                                    .frame(maxWidth: 60, maxHeight: 60)
                                    .background(selectedType == type.name ? .green : .yellow)
                                Text(type.name)
                                    .font(.custom("Small", size: 10))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: 60, minHeight: 24)
                                    .background(.white)
                                    
                            }
                                
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(.buttonBorder)
                        .foregroundStyle(.black)
                        .shadow(radius: 2, x: 1, y: 1)
                    }
                    Button {
                        showingAddType = true
                    }label: {
                        Image(systemName:"plus")
                            .fontWeight(.heavy)
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                    }
                    .frame(width: 50, height: 50)
                    .background(.green)
                    .clipShape(.circle)
                    .shadow(radius: 2, x: 1, y: 1)
                }
            }
        }
    }
}

#Preview {
    AddView(expenseMap: ExpneseMap())
}
