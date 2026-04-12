import Foundation

struct RedeemResponse: Codable {
    let links: [RedeemLink]?
    let details: RedeemDetails?
}

struct RedeemLink: Codable {
    let rel: String
    let href: String?
}

struct RedeemDetails: Codable {
    let link: String?
    let promoCode: String?

    enum CodingKeys: String, CodingKey {
        case link
        case promoCode = "promo_code"
    }
}

protocol RedeemRepositoryProtocol {
    func redeemOffer(offerKey: Int, firstName: String, lastName: String, memberId: String) async throws -> RedeemResponse
    func redeemOfferMethod(offerKey: Int, firstName: String, lastName: String, memberId: String, method: String) async throws -> RedeemResponse
}
