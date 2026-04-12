import Foundation

final class PaymentRepository: PaymentRepositoryProtocol {
    private let apiClient: APIClient
    private let keychain: KeychainManager

    init(apiClient: APIClient = APIClient(), keychain: KeychainManager = .shared) {
        self.apiClient = apiClient
        self.keychain = keychain
    }

    func createSubscriptionIntent(membershipType: String, email: String, name: String, userId: Int) async throws -> SubscriptionIntent {
        struct Body: Encodable {
            let membershipType: String
            let email: String
            let name: String
            let userId: Int
        }

        var headers: [String: String] = [:]
        if let token = keychain.get(.authToken) {
            headers["Authorization"] = "Bearer \(token)"
        }

        let request = APIRequest(
            path: "/api/create-subscription-intent",
            method: .post,
            body: Body(membershipType: membershipType, email: email, name: name, userId: userId),
            headers: headers
        )

        return try await apiClient.request(baseURL: AppEnvironment.backendURL, request)
    }

    func createCheckoutSession(membershipType: String, userId: Int, returnUrl: String) async throws -> CheckoutSession {
        struct Body: Encodable {
            let membershipType: String
            let userId: Int
            let returnUrl: String
        }

        var headers: [String: String] = [:]
        if let token = keychain.get(.authToken) {
            headers["Authorization"] = "Bearer \(token)"
        }

        let request = APIRequest(
            path: "/api/stripe-checkout",
            method: .post,
            body: Body(membershipType: membershipType, userId: userId, returnUrl: returnUrl),
            headers: headers
        )

        return try await apiClient.request(baseURL: AppEnvironment.backendURL, request)
    }

    func createPortalSession(customerId: String) async throws -> String {
        struct Body: Encodable { let customerId: String }
        struct Response: Decodable { let url: String }

        var headers: [String: String] = [:]
        if let token = keychain.get(.authToken) {
            headers["Authorization"] = "Bearer \(token)"
        }

        let request = APIRequest(
            path: "/api/create-portal-session",
            method: .post,
            body: Body(customerId: customerId),
            headers: headers
        )

        let response: Response = try await apiClient.request(baseURL: AppEnvironment.backendURL, request)
        return response.url
    }
}
