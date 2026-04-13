import Foundation

final class AuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    private let apiClient: APIClient
    private let keychain: KeychainManager

    init(apiClient: APIClient = APIClient(), keychain: KeychainManager = .shared) {
        self.apiClient = apiClient
        self.keychain = keychain
    }

    func signIn(email: String, password: String) async throws -> User {
        struct SignInBody: Encodable {
            let email: String
            let password: String
        }

        struct SignInResponse: Decodable {
            let user: User?
            let token: AuthToken?
            let error: String?
        }

        let request = APIRequest(
            path: "/api/auth/signin",
            method: .post,
            body: SignInBody(email: email, password: password)
        )

        let response: SignInResponse = try await apiClient.request(
            baseURL: AppEnvironment.backendURL,
            request
        )

        if let error = response.error {
            throw AppError.validationError(error)
        }

        guard let user = response.user else {
            throw AppError.unknown("Invalid sign in response")
        }

        if let token = response.token {
            keychain.save(token.accessToken, for: .authToken)
            if let refresh = token.refreshToken {
                keychain.save(refresh, for: .refreshToken)
            }
        }

        keychain.save(email, for: .userEmail)
        return user
    }

    func signUp(request: SignUpRequest) async throws -> User {
        struct SignUpResponse: Decodable {
            let message: String?
            let user: User?
            let error: String?
        }

        let apiRequest = APIRequest(
            path: "/api/signup",
            method: .post,
            body: request
        )

        let response: SignUpResponse = try await apiClient.request(
            baseURL: AppEnvironment.backendURL,
            apiRequest
        )

        if let error = response.error {
            throw AppError.validationError(error)
        }

        guard let user = response.user else {
            throw AppError.unknown("Invalid sign up response")
        }

        return user
    }

    func signOut() async {
        keychain.clearAll()
    }

    func forgotPassword(email: String) async throws -> String {
        struct Body: Encodable { let email: String }
        struct Response: Decodable {
            let message: String?
            let error: String?
        }

        let request = APIRequest(path: "/api/forget-password", method: .post, body: Body(email: email))
        let response: Response = try await apiClient.request(baseURL: AppEnvironment.backendURL, request)

        if let error = response.error {
            throw AppError.validationError(error)
        }
        return response.message ?? "Password reset link sent"
    }

    func resetPassword(token: String, newPassword: String) async throws -> String {
        struct Body: Encodable { let token: String; let password: String }
        struct Response: Decodable {
            let message: String?
            let error: String?
        }

        let request = APIRequest(path: "/api/reset-password", method: .post, body: Body(token: token, password: newPassword))
        let response: Response = try await apiClient.request(baseURL: AppEnvironment.backendURL, request)

        if let error = response.error {
            throw AppError.validationError(error)
        }
        return response.message ?? "Password reset successfully"
    }

    func getCurrentUser() async throws -> User? {
        guard keychain.get(.authToken) != nil else { return nil }
        return try await getProfile()
    }

    func getProfile() async throws -> User {
        guard let token = keychain.get(.authToken) else {
            throw AppError.unauthorized
        }

        let request = APIRequest(
            path: "/api/user/profile",
            method: .get,
            headers: ["Authorization": "Bearer \(token)"]
        )

        return try await apiClient.request(baseURL: AppEnvironment.backendURL, request)
    }

    func changePassword(currentPassword: String, newPassword: String) async throws -> String {
        guard let token = keychain.get(.authToken) else {
            throw AppError.unauthorized
        }

        struct Body: Encodable {
            let currentPassword: String
            let newPassword: String
        }
        struct Response: Decodable {
            let message: String?
            let error: String?
        }

        let request = APIRequest(
            path: "/api/user/change-password",
            method: .post,
            body: Body(currentPassword: currentPassword, newPassword: newPassword),
            headers: ["Authorization": "Bearer \(token)"]
        )

        let response: Response = try await apiClient.request(baseURL: AppEnvironment.backendURL, request)

        if let error = response.error {
            throw AppError.validationError(error)
        }
        return response.message ?? "Password changed successfully"
    }
}
