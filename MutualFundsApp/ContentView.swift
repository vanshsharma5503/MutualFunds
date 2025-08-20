//
//  ContentView.swift
//  MutualFundsApp
//
//  Created by Vansh Sharma on 20/08/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
            TabView {
                Fund_Selection_Screen()
                    .tabItem {
                        Label("Funds", systemImage: "list.bullet")
                    }
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
            }
        }
    }

#Preview {
    ContentView()
}
