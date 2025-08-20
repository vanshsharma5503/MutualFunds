//
//  UserManager.swift
//  MutualFundsApp
//
//  Created by Vansh Sharma on 21/08/25.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class UserManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userEmail: String = ""
    @Published var username: String = ""
    @Published var selectedFunds: [Funds] = []
    @Published var pastViewedFunds: [Funds] = []
    
    private var db = Firestore.firestore()
    
    // MARK: - Init
    init() {
        if let currentUser = Auth.auth().currentUser {
            self.isLoggedIn = true
            self.userEmail = currentUser.email ?? ""
            loadUserData()
        }
    }
    
    // MARK: - Logout
    func logout() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            self.userEmail = ""
            self.selectedFunds = []
            self.pastViewedFunds = []
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Save Selected Fund
    func saveSelectedFund(_ fund: Funds) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if !selectedFunds.contains(where: { $0.schemeCode == fund.schemeCode }) {
            selectedFunds.append(fund)
        }
        
        let data = selectedFunds.map {
            [
                "schemeCode": $0.schemeCode,
                "schemeName": $0.schemeName,
                "isinGrowth": $0.isinGrowth as Any,
                "isinDivReinvestment": $0.isinDivReinvestment as Any
            ]
        }
        
        db.collection("users")
            .document(uid)
            .setData(["selectedFunds": data], merge: true)
    }
    
    // MARK: - Save Past Viewed Fund
    func savePastViewedFund(_ fund: Funds) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if !pastViewedFunds.contains(where: { $0.schemeCode == fund.schemeCode }) {
            pastViewedFunds.append(fund)
        }
        
        let data = pastViewedFunds.map {
            [
                "schemeCode": $0.schemeCode,
                "schemeName": $0.schemeName,
                "isinGrowth": $0.isinGrowth as Any,
                "isinDivReinvestment": $0.isinDivReinvestment as Any
            ]
        }
        
        db.collection("users")
            .document(uid)
            .setData(["pastViewedFunds": data], merge: true)
    }
    
    // MARK: - Load User Data
    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).getDocument { snapshot, _ in
            if let data = snapshot?.data() {
                
                // Load Selected Funds
                if let selected = data["selectedFunds"] as? [[String: Any]] {
                    self.selectedFunds = selected.compactMap { dict in
                        (dict["schemeCode"] as? Int).flatMap { code in
                            (dict["schemeName"] as? String).map { name in
                                Funds(
                                    schemeCode: code,
                                    schemeName: name,
                                    isinGrowth: dict["isinGrowth"] as? String,
                                    isinDivReinvestment: dict["isinDivReinvestment"] as? String
                                )
                            }
                        }
                    }
                }
                
                // Load Past Viewed Funds
                if let viewed = data["pastViewedFunds"] as? [[String: Any]] {
                    self.pastViewedFunds = viewed.compactMap { dict in
                        (dict["schemeCode"] as? Int).flatMap { code in
                            (dict["schemeName"] as? String).map { name in
                                Funds(
                                    schemeCode: code,
                                    schemeName: name,
                                    isinGrowth: dict["isinGrowth"] as? String,
                                    isinDivReinvestment: dict["isinDivReinvestment"] as? String
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

