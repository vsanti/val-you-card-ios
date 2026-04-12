import Foundation

enum AppEnvironment {
    static var apiURL: String {
        Bundle.main.infoDictionary?["API_URL"] as? String ?? ""
    }

    static var redeemAPIURL: String {
        Bundle.main.infoDictionary?["REDEEM_API_URL"] as? String ?? ""
    }

    static var strapiURL: String {
        Bundle.main.infoDictionary?["STRAPI_URL"] as? String ?? ""
    }

    static var backendURL: String {
        Bundle.main.infoDictionary?["BACKEND_URL"] as? String ?? ""
    }

    static var accessToken: String {
        Bundle.main.infoDictionary?["ACCESS_TOKEN"] as? String ?? ""
    }

    static var memberKey: String {
        Bundle.main.infoDictionary?["MEMBER_KEY"] as? String ?? ""
    }

    static var stripePublishableKey: String {
        Bundle.main.infoDictionary?["STRIPE_PUBLISHABLE_KEY"] as? String ?? ""
    }

    /// Default query parameters for the deals API
    static var dealsAPIQueryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "access_token", value: accessToken),
            URLQueryItem(name: "member_key", value: memberKey),
        ]
    }
}
