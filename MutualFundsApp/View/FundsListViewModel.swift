//
//  FundsListViewModel.swift
//  MutualFundsApp
//
//  Created by Vansh Sharma on 20/08/25.
//

import Foundation
import Combine

@MainActor
final class FundsListViewModel: ObservableObject {
    @Published var funds: [Funds] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // 🔹 Extracted AMC list from all funds
    @Published var amcList: [String] = []

    func getFunds() async {
        isLoading = true
        do {
            let allFunds = try await WebServices.getFundsData()
            self.funds = allFunds
            
            // Extract AMC names from schemeName (e.g., "HDFC Equity Fund" -> "HDFC")
            let amcs = allFunds.map { fund -> String in
                let words = fund.schemeName.split(separator: " ")
                // take first two words for better accuracy
                return words.prefix(2).joined(separator: " ")
            }
            
            self.amcList = Array(Set(amcs)).sorted()
            
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
