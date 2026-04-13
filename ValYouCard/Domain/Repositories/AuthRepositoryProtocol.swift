import Foundation

protocol AuthRepositoryProtocol: Sendable {
    func signIn(email: String, password: String) async throws -> User
    func signUp(request: SignUpRequest) async throws -> User
    func signOut() async
    func forgotPassword(email: String) async throws -> String
    func resetPassword(token: String, newPassword: String) async throws -> String
    func getCurrentUser() async throws -> User?
    func getProfile() async throws -> User
    func changePassword(currentPassword: String, newPassword: String) async throws -> String
}
