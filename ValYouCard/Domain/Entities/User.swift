import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: Int
    let email: String
    let name: String?
    let member: Bool
    let memberId: String?
    let stripeCustomerId: String?
    let stripePaymentId: String?
    let membershipType: String?
    let membershipStart: Date?
    let membershipEnd: Date?
}

struct AuthToken: Codable, Equatable {
    let accessToken: String
    let refreshToken: String?
}

struct AuthResponse: Codable {
    let message: String?
    let user: User?
    let token: AuthToken?
    let error: String?
}

struct SignUpRequest: Encodable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
}

struct SignInRequest: Encodable {
    let email: String
    let password: String
}
