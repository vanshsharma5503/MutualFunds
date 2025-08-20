//
//  WebServices.swift
//  MutualFundsApp
//
//  Created by Vansh Sharma on 20/08/25.
//
import Foundation

final class WebServices {
    
    static func getFundsData() async throws -> [Funds] {
        let funds: [Funds] = try await fetch(urlString: "https://api.mfapi.in/mf")
        print("✅ Got \(funds.count) funds")
        return funds
    }

    static func getFundDetail(schemeCode: Int) async throws -> Funds {
        let details: FundsDetail = try await fetch(urlString: "https://api.mfapi.in/mf/\(schemeCode)")
        let meta = details.meta
        return Funds(
            schemeCode: meta.schemeCode,
            schemeName: meta.schemeName,
            isinGrowth: meta.isinGrowth,
            isinDivReinvestment: meta.isinDivReinvestment,
            fundHouse: meta.fundHouse,
            schemeType: meta.schemeType,
            schemeCategory: meta.schemeCategory
        )
    }

    private static func fetch<T: Decodable>(urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw Errors.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw Errors.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("❌ Decoding error: \(error)")
            throw Errors.invalidData
        }
    }
    
    static func filterFundsByAMC(_ funds: [Funds], amcName: String) -> [Funds] {
        funds.filter { $0.fundHouse?.localizedCaseInsensitiveContains(amcName) == true }
    }

    static func filterFundsByCategory(_ funds: [Funds], category: String) -> [Funds] {
        funds.filter { $0.schemeCategory?.localizedCaseInsensitiveContains(category) == true }
    }
}

enum Errors: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .invalidResponse: return "Invalid response."
        case .invalidData: return "Invalid data."
        }
    }
}
