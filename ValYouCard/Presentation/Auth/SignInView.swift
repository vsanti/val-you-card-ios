import SwiftUI

struct SignInView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var showSignUp = false
    @State private var showForgotPassword = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(AppTheme.orange)

                    Text("Val-You Card")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Sign in to access exclusive deals")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)

                // Error/Success Messages
                if let error = auth.errorMessage {
                    ErrorBanner(message: error) {
                        auth.errorMessage = nil
                    }
                }

                if let success = auth.successMessage {
                    SuccessBanner(message: success)
                }

                // Form
                VStack(spacing: 16) {
                    TextField("Email", text: $auth.signInEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    SecureField("Password", text: $auth.signInPassword)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    PrimaryButton(title: "Sign In", isLoading: auth.isLoading) {
                        Task { await auth.signIn() }
                    }

                    Button("Forgot Password?") {
                        showForgotPassword = true
                    }
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.blue)
                }

                Divider()

                // Sign Up
                VStack(spacing: 12) {
                    Text("Don't have an account?")
                        .foregroundStyle(.secondary)

                    PrimaryButton(title: "Create Account", style: .outline) {
                        showSignUp = true
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSignUp) {
            NavigationStack {
                SignUpView()
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            NavigationStack {
                ForgotPasswordView()
            }
        }
    }
}
