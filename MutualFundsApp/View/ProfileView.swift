////
////  ProfileView.swift
////  MutualFundsApp
////
////  Created by Vansh Sharma on 20/08/25.
////
//
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // MARK: - Avatar + Greeting
                        VStack(spacing: 10) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                            
                            Text("Hello, \(userManager.username.isEmpty ? userManager.userEmail : userManager.username) 👋")
                                .font(.title2)
                                .bold()
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        
                        // MARK: - Selected Funds Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("⭐ Selected Funds")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            if userManager.selectedFunds.isEmpty {
                                Text("No selected funds yet.")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            } else {
                                ForEach(userManager.selectedFunds, id: \.schemeCode) { fund in
                                    HStack {
                                        Text(fund.schemeName)
                                            .font(.subheadline)
                                        Spacer()
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.vertical, 4)
                                    .padding(.horizontal)
                                    .background(Color.white.opacity(0.7))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(12)
                        
                        // MARK: - Past Viewed Funds Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("📊 Past Viewed Funds")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            if userManager.pastViewedFunds.isEmpty {
                                Text("No funds viewed yet.")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            } else {
                                ForEach(userManager.pastViewedFunds, id: \.schemeCode) { fund in
                                    HStack {
                                        Text(fund.schemeName)
                                            .font(.subheadline)
                                        Spacer()
                                        Image(systemName: "clock.fill")
                                            .foregroundColor(.orange)
                                    }
                                    .padding(.vertical, 4)
                                    .padding(.horizontal)
                                    .background(Color.white.opacity(0.7))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(12)
                        
                        Spacer()
                        
                        // MARK: - Logout Button
                        Button(action: {
                            userManager.logout()
                        }) {
                            Text("Logout")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                    .padding()
                }
                .navigationTitle("Profile")
            }
        }
    }
}
