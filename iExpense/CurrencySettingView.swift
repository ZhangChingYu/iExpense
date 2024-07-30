//
//  CurrencySettingView.swift
//  iExpense
//
//  Created by Sunny on 2024/7/29.
//

import SwiftUI

struct CurrencySettingView: View {
    
    var currencySetting: CurrencySetting
    @State private var currencyId = ""
    @State private var currency = 1.0
    @State private var showingEdit = false
    
    var body: some View {
        NavigationStack {
            Form{
                Section{
                    ForEach(currencySetting.settings){ setting in
                        HStack {
                            Text(setting.id)
                                .fontWeight(.bold)
                            Spacer()
                            Text(setting.rate.formatted())
                                .foregroundStyle(setting.id == "USD" ? .black : .blue)
                        }
                        .onTapGesture {
                            showingEdit = true
                            currencyId = setting.id
                            currency = setting.rate
                        }
                    }
                }
                if showingEdit {
                    Section {
                        HStack(alignment: .center) {
                            Text(currencyId)
                                .frame(maxWidth: 60)
                            Spacer()
                            TextField("currency rate", value: $currency, format: .number.precision(.fractionLength(2)))
                                .frame(maxWidth: 60)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .toolbar {
                if showingEdit {
                    Button("Save"){
                        for i in 0..<currencySetting.settings.count {
                            if currencySetting.settings[i].id == currencyId {
                                currencySetting.settings[i].rate = currency
                            }
                        }
                        showingEdit = false
                    }
                }
            }
        }
    }
}

#Preview {
    CurrencySettingView(currencySetting: CurrencySetting())
}
