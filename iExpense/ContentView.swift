//
//  ContentView.swift
//  iExpense
//
//  Created by Sunny on 2024/7/28.
//

import Observation
import SwiftUI

struct PriceModifier: ViewModifier {
    let price: Double
    func body(content: Content) -> some View {
        if price <= 10 {
            return content.foregroundStyle(.yellow)
        } else if price <= 100 {
            return content.foregroundStyle(.orange)
        } else {
            return content.foregroundStyle(.red)
        }
    }
}

extension View {
    func Price(price: Double) -> some View{
        modifier(PriceModifier(price: price))
    }
}


// Identifiable will make this item unique somehow
// 4. make ExpenseItem Codable
struct ExpenseItem: Identifiable, Codable {
    // swift will generate a unique sequence for each item
    var id = UUID()
    let name: String
    let type: String
    let currencyCode: String
    let amount: Double
    
}

@Observable
class ExpneseMap {
    var expenses = [String: [ExpenseItem]]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(expenses) {
                UserDefaults.standard.set(encoded, forKey:"Expenses")
            }
        }
    }
    init() {
        if let saveExpenses = UserDefaults.standard.data(forKey: "Expenses") {
            if let decodedExpenses = try? JSONDecoder().decode([String: [ExpenseItem]].self, from: saveExpenses) {
                expenses = decodedExpenses
                return
            }
        }
    }
}

struct Currency: Identifiable, Codable {
    var id: String
    var rate: Double
}

@Observable
class CurrencySetting {
    var settings = [Currency]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(settings) {
                UserDefaults.standard.set(encoded, forKey: "ExchangeRate")
            }
        }
    }
    init() {
        if let saveCurrency = UserDefaults.standard.data(forKey: "ExchangeRate") {
            if let decodedCurrency = try? JSONDecoder().decode([Currency].self, from: saveCurrency) {
                settings = decodedCurrency
                return
            }
        }
        settings = [
            Currency(id: "USD", rate: 1),
            Currency(id: "TWD", rate: 32.88),
            Currency(id: "AUD", rate: 1.53),
            Currency(id: "CNY", rate: 7.26)
        ]
    }
}

struct ContentView: View {
    @State private var expenseMap = ExpneseMap()
    @State private var showingAddExpense = false
    @State private var currencySetting = CurrencySetting()
    
    @AppStorage("PreviewCurrency") var previewCurrency: String = "TWD"

    var totalAmount: Double {
        calculateTotal()
    }
    let currencyCodes = ["USD", "TWD", "AUD", "CNY"]
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Preview Currency", selection: $previewCurrency) {
                        ForEach(currencyCodes, id: \.self){
                            Text($0)
                        }
                    }
                    VStack (alignment: .leading, spacing: 10) {
                        Text("Total Amount: ")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text(totalAmount, format: .currency(code: previewCurrency))
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                    }
                    .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                }
                ForEach(Array(expenseMap.expenses.keys), id: \.self){ key in
                    Section(key) {
                        ForEach(expenseMap.expenses[key] ?? []){ item in
                            HStack {
                                Text(item.name)
                                    .font(.headline)
                                Spacer()
                                Text(item.amount, format: .currency(code: item.currencyCode))
                                    .Price(price: item.amount)
                            }
                        }
                        .onDelete { indexSet in
                            removeItems(at: indexSet, type: key)
                        }
                    }
                }
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button("Add expense", systemImage: "plus"){
                    showingAddExpense = true
                }
                Button("Add Type", systemImage: "eye"){
                    print(expenseMap.expenses)
                    print(Locale.current.currency?.identifier ?? "no")
                }
                NavigationLink(destination: CurrencySettingView(currencySetting: currencySetting)){
                    Button("", systemImage: "gear"){}
                }
               
            }
            .sheet(isPresented: $showingAddExpense){
                // show an AddView here
                AddView(expenseMap: expenseMap)
            }
        }
    }
    func removeItems(at offset: IndexSet, type: String) {
        expenseMap.expenses[type]?.remove(atOffsets: offset)
    }
    
    func calculateTotal() -> Double{
        var usd = 0.0
        // 先換成美金，再換成目標貨幣
        for key in expenseMap.expenses.keys {
            if let items = expenseMap.expenses[key] {
                for item in items {
                    for currency in currencySetting.settings {
                        if currency.id == item.currencyCode {
                            usd += item.amount/currency.rate
                            break
                        }
                    }
                }
            }
        }
        if previewCurrency == "USD" {
            return usd
        } else {
            for currency in currencySetting.settings {
                if previewCurrency == currency.id {
                    return usd * currency.rate
                }
            }
        }
        return usd
    }
}

#Preview {
    ContentView()
}
