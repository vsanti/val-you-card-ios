import Foundation

struct SubscriptionIntent: Codable {
    let clientSecret: String
    let customerId: String?
}

struct CheckoutSession: Codable {
    let url: String
    let sessionId: String
}

protocol PaymentRepositoryProtocol: Sendable {
    func createSubscriptionIntent(membershipType: String, email: String, name: String, userId: Int) async throws -> SubscriptionIntent
    func createCheckoutSession(membershipType: String, userId: Int, returnUrl: String) async throws -> CheckoutSession
    func createPortalSession(customerId: String) async throws -> String
}
