//
//  MutualFundsAppApp.swift
//  MutualFundsApp
//
//  Created by Vansh Sharma on 20/08/25.
//

import SwiftUI
import Combine
import Firebase   // ⬅️ Add this

@main
struct MutualFundsAppApp: App {
    @StateObject private var userManager = UserManager()
    
    // 🔹 Initialize Firebase before anything else
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if userManager.isLoggedIn {
                TabView {
                    Fund_Selection_Screen()
                        .tabItem {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Funds")
                        }
                        .environmentObject(userManager)
                    
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person.circle")
                            Text("Profile")
                        }
                        .environmentObject(userManager)
                }
            } else {
                LoginView()
                    .environmentObject(userManager)
            }
        }
    }
}

