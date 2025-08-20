//
//  AMCLIST.swift
//  MutualFundsApp
//
//  Created by Vansh Sharma on 20/08/25.
//
import SwiftUI

struct AMCLIST: View {
    @StateObject private var viewModel = FundsListViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(uniqueAMCs, id: \.self) { amc in
                    Text(amc)
                }
            }
            .navigationTitle("AMC List")
            .task {
                await viewModel.getFunds()
            }
        }
    }
    
    private var uniqueAMCs: [String] {
        let amcs = viewModel.funds.compactMap { fund -> String? in
            let name = fund.schemeName
            if let firstWord = name.split(separator: " ").first {
                return String(firstWord)
            }
            return nil
        }
        return Array(Set(amcs)).sorted()
    }
}


// MARK: - Preview
#Preview {
    AMCLIST()
}
