import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.rotation")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.orange)

            VStack(spacing: 8) {
                Text("Reset Password")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Enter your email and we'll send you a link to reset your password")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let error = auth.errorMessage {
                ErrorBanner(message: error) {
                    auth.errorMessage = nil
                }
            }

            if let success = auth.successMessage {
                SuccessBanner(message: success)
            }

            TextField("Email", text: $auth.forgotPasswordEmail)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            PrimaryButton(title: "Send Reset Link", isLoading: auth.isLoading) {
                Task { await auth.forgotPassword() }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .navigationTitle("Forgot Password")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }
}
