//
//  LoginView.swift
//  MutualFundsApp
//
//  Created by Vansh Sharma on 20/08/25.
//
import SwiftUI
import FirebaseAuth

// MARK: - Login View
struct LoginView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Title
                    Text("Login")
                        .font(.system(size: 40, weight: .bold))

                    // Email
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)

                    // Password
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)

                    // Error message
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }

                    // Login button
                    Button {
                        loginUser()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Login")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(isLoading)

                    // Navigate to signup
                    Button("Don’t have an account? Sign up") {
                        showSignUp = true
                    }
                    .font(.footnote)
                    .padding(.top, 10)

                    Spacer()
                }
                .padding()
                .navigationDestination(isPresented: $showSignUp) {
                    SignUpView()
                        .environmentObject(userManager)
                }
            }
        }
    }

    // MARK: - Login function
    private func loginUser() {
        isLoading = true
        errorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
            } else if let user = result?.user {
                userManager.userEmail = user.email ?? ""
                userManager.isLoggedIn = true
            }
        }
    }
}

// MARK: - Signup View
struct SignUpView: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) var dismiss

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Title
                    Text("Sign Up")
                        .font(.system(size: 40, weight: .bold))
                        .padding(.top, 40)

                    // Username
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)

                    // Email
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)

                    // Password
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)

                    // Error message
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Signup button
                    Button {
                        registerUser()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Create Account")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(isLoading)

                    // Back to login
                    Button("Already have an account? Log in") {
                        dismiss()
                    }
                    .font(.footnote)
                    .padding(.top, 10)

                    Spacer()
                }
                .padding()
            }
        }
    }

    // MARK: - Register function
    private func registerUser() {
        isLoading = true
        errorMessage = nil

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            self.isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else if let user = result?.user {
                // Save user info in UserManager
                self.userManager.userEmail = user.email ?? ""
                self.userManager.username = username   // ✅ store username
                self.userManager.isLoggedIn = true
                self.dismiss()
            }
        }
    }
}
