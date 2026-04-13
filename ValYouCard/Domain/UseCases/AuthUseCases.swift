import Foundation

protocol SignInUseCaseProtocol: Sendable {
    func execute(email: String, password: String) async throws -> User
}

protocol SignUpUseCaseProtocol: Sendable {
    func execute(request: SignUpRequest) async throws -> User
}

protocol ForgotPasswordUseCaseProtocol: Sendable {
    func execute(email: String) async throws -> String
}

protocol GetProfileUseCaseProtocol: Sendable {
    func execute() async throws -> User
}

protocol ChangePasswordUseCaseProtocol: Sendable {
    func execute(currentPassword: String, newPassword: String) async throws -> String
}

// MARK: - Implementations

struct SignInUseCase: SignInUseCaseProtocol {
    let repository: AuthRepositoryProtocol

    func execute(email: String, password: String) async throws -> User {
        try await repository.signIn(email: email, password: password)
    }
}

struct SignUpUseCase: SignUpUseCaseProtocol {
    let repository: AuthRepositoryProtocol

    func execute(request: SignUpRequest) async throws -> User {
        try await repository.signUp(request: request)
    }
}

struct ForgotPasswordUseCase: ForgotPasswordUseCaseProtocol {
    let repository: AuthRepositoryProtocol

    func execute(email: String) async throws -> String {
        try await repository.forgotPassword(email: email)
    }
}

struct GetProfileUseCase: GetProfileUseCaseProtocol {
    let repository: AuthRepositoryProtocol

    func execute() async throws -> User {
        try await repository.getProfile()
    }
}

struct ChangePasswordUseCase: ChangePasswordUseCaseProtocol {
    let repository: AuthRepositoryProtocol

    func execute(currentPassword: String, newPassword: String) async throws -> String {
        try await repository.changePassword(currentPassword: currentPassword, newPassword: newPassword)
    }
}
