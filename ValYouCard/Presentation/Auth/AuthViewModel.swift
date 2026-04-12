import Foundation
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // Sign In fields
    @Published var signInEmail = ""
    @Published var signInPassword = ""

    // Sign Up fields
    @Published var signUpFirstName = ""
    @Published var signUpLastName = ""
    @Published var signUpEmail = ""
    @Published var signUpPassword = ""
    @Published var signUpConfirmPassword = ""

    // Forgot Password
    @Published var forgotPasswordEmail = ""

    private let signInUseCase: SignInUseCaseProtocol
    private let signUpUseCase: SignUpUseCaseProtocol
    private let forgotPasswordUseCase: ForgotPasswordUseCaseProtocol
    private let getProfileUseCase: GetProfileUseCaseProtocol
    private let authRepository: AuthRepositoryProtocol

    init(
        signInUseCase: SignInUseCaseProtocol,
        signUpUseCase: SignUpUseCaseProtocol,
        forgotPasswordUseCase: ForgotPasswordUseCaseProtocol,
        getProfileUseCase: GetProfileUseCaseProtocol,
        authRepository: AuthRepositoryProtocol
    ) {
        self.signInUseCase = signInUseCase
        self.signUpUseCase = signUpUseCase
        self.forgotPasswordUseCase = forgotPasswordUseCase
        self.getProfileUseCase = getProfileUseCase
        self.authRepository = authRepository
    }

    func restoreSession() async {
        do {
            if let user = try await authRepository.getCurrentUser() {
                currentUser = user
                isAuthenticated = true
            }
        } catch {
            // No stored session, user stays logged out
        }
    }

    func signIn() async {
        guard !signInEmail.isEmpty, !signInPassword.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let user = try await signInUseCase.execute(email: signInEmail, password: signInPassword)
            currentUser = user
            isAuthenticated = true
            clearSignInFields()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signUp() async {
        guard !signUpFirstName.isEmpty, !signUpLastName.isEmpty,
              !signUpEmail.isEmpty, !signUpPassword.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }

        guard signUpPassword == signUpConfirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        guard signUpPassword.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let request = SignUpRequest(
                firstName: signUpFirstName,
                lastName: signUpLastName,
                email: signUpEmail,
                password: signUpPassword
            )
            _ = try await signUpUseCase.execute(request: request)
            successMessage = "Account created! Please sign in."
            clearSignUpFields()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func forgotPassword() async {
        guard !forgotPasswordEmail.isEmpty else {
            errorMessage = "Please enter your email"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let message = try await forgotPasswordUseCase.execute(email: forgotPasswordEmail)
            successMessage = message
            forgotPasswordEmail = ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signOut() async {
        await authRepository.signOut()
        currentUser = nil
        isAuthenticated = false
    }

    func refreshProfile() async {
        do {
            currentUser = try await getProfileUseCase.execute()
        } catch {
            // Silently fail on refresh
        }
    }

    private func clearSignInFields() {
        signInEmail = ""
        signInPassword = ""
    }

    private func clearSignUpFields() {
        signUpFirstName = ""
        signUpLastName = ""
        signUpEmail = ""
        signUpPassword = ""
        signUpConfirmPassword = ""
    }
}
