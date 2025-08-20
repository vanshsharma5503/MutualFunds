//
//  Funds.swift
//  MutualFundsApp
//
//  Created by Vansh Sharma on 20/08/25.
//

import Foundation


struct Funds: Codable, Identifiable {
    var id: Int { schemeCode }
    let schemeCode: Int
    let schemeName: String
    let isinGrowth, isinDivReinvestment: String?
    
    // Extra info (fetched from detail API)
    var fundHouse: String?
    var schemeType: String?
    var schemeCategory: String?
    
    // Firestore-friendly dictionary
    func toDict() -> [String: Any] {
        return [
            "schemeCode": schemeCode,
            "schemeName": schemeName,
            "isinGrowth": isinGrowth ?? "",
            "isinDivReinvestment": isinDivReinvestment ?? "",
            "fundHouse": fundHouse ?? "",
            "schemeType": schemeType ?? "",
            "schemeCategory": schemeCategory ?? ""
        ]
    }
    
    init?(dict: [String: Any]) {
        guard let schemeCode = dict["schemeCode"] as? Int,
              let schemeName = dict["schemeName"] as? String else {
            return nil
        }
        self.schemeCode = schemeCode
        self.schemeName = schemeName
        self.isinGrowth = dict["isinGrowth"] as? String
        self.isinDivReinvestment = dict["isinDivReinvestment"] as? String
        self.fundHouse = dict["fundHouse"] as? String
        self.schemeType = dict["schemeType"] as? String
        self.schemeCategory = dict["schemeCategory"] as? String
    }
    
    init(
        schemeCode: Int,
        schemeName: String,
        isinGrowth: String? = nil,
        isinDivReinvestment: String? = nil,
        fundHouse: String? = nil,
        schemeType: String? = nil,
        schemeCategory: String? = nil
    ) {
        self.schemeCode = schemeCode
        self.schemeName = schemeName
        self.isinGrowth = isinGrowth
        self.isinDivReinvestment = isinDivReinvestment
        self.fundHouse = fundHouse
        self.schemeType = schemeType
        self.schemeCategory = schemeCategory
    }
}

struct FundsDetail: Codable {
    let meta: Meta
    let data: [Datum]
    let status: String
}

struct Datum: Codable {
    let date, nav: String
}

struct Meta: Codable {
    let fundHouse, schemeType, schemeCategory: String
    let schemeCode: Int
    let schemeName: String
    let isinGrowth, isinDivReinvestment: String?

    enum CodingKeys: String, CodingKey {
        case fundHouse = "fund_house"
        case schemeType = "scheme_type"
        case schemeCategory = "scheme_category"
        case schemeCode = "scheme_code"
        case schemeName = "scheme_name"
        case isinGrowth = "isin_growth"
        case isinDivReinvestment = "isin_div_reinvestment"
    }
}
