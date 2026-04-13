import Foundation

struct OffersQuery {
    var page: Int = 1
    var query: String?
    var categoryKeys: [Int]?
    var sort: String = "distance"
    var lat: Double?
    var lon: Double?
    var postalCode: String?
    var online: String?
    var offerType: String?
    var distance: String = "50mi"
}

struct StoreOffersQuery {
    var storeKey: String
    var page: Int = 1
    var locationKey: Int?
}

protocol OffersRepositoryProtocol: Sendable {
    func getAllOffers(query: OffersQuery) async throws -> OffersResponse
    func getStoreOffers(query: StoreOffersQuery) async throws -> OffersResponse
    func getNewOffers() async throws -> OffersResponse
    func getFeaturedOffers() async throws -> [FeaturedOffer]
    func getAutocomplete(query: String) async throws -> [String]
}
