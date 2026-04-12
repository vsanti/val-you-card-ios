import Foundation

struct Offer: Identifiable, Codable, Equatable, Hashable {
    var id: Int { offerKey }

    let offerKey: Int
    let title: String
    let logoUrl: String
    let savingsAmount: String
    let categories: [Category]
    let offerStore: OfferStore
    let termsOfUse: String
    let searchDistance: Double

    enum CodingKeys: String, CodingKey {
        case offerKey = "offer_key"
        case title
        case logoUrl = "logo_url"
        case savingsAmount = "savings_amount"
        case categories
        case offerStore = "offer_store"
        case termsOfUse = "terms_of_use"
        case searchDistance = "search_distance"
    }
}

struct OfferStore: Codable, Equatable, Hashable {
    let name: String
    let description: String
    let storeKey: Int
    let physicalLocation: PhysicalLocation

    enum CodingKeys: String, CodingKey {
        case name, description
        case storeKey = "store_key"
        case physicalLocation = "physical_location"
    }
}

struct PhysicalLocation: Codable, Equatable, Hashable {
    let locationName: String?
    let locationKey: Int
    let webAddress: String?
    let description: String?
    let postalCode: String?
    let country: String?
    let streetAddress: String?
    let extendedStreetAddress: String?
    let cityLocality: String?
    let stateRegion: String?

    enum CodingKeys: String, CodingKey {
        case locationName = "location_name"
        case locationKey = "location_key"
        case webAddress = "web_address"
        case description
        case postalCode = "postal_code"
        case country
        case streetAddress = "street_address"
        case extendedStreetAddress = "extended_street_address"
        case cityLocality = "city_locality"
        case stateRegion = "state_region"
    }

    var formattedAddress: String? {
        var parts: [String] = []
        if let street = streetAddress, !street.isEmpty { parts.append(street) }
        if let city = cityLocality, !city.isEmpty { parts.append(city) }
        if let state = stateRegion, !state.isEmpty { parts.append(state) }
        if let zip = postalCode, !zip.isEmpty { parts.append(zip) }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}

struct OffersResponse: Codable {
    let offers: [Offer]
    let info: OffersInfo
    let offerCountInCategories: [OfferCategoryCount]?

    enum CodingKeys: String, CodingKey {
        case offers, info
        case offerCountInCategories = "offer_count_in_categories"
    }
}

struct OffersInfo: Codable {
    let totalResults: Int
    let currentPage: Int
    let resultsPerPage: Int
    let totalPages: Int?
    let totalStores: Int?

    enum CodingKeys: String, CodingKey {
        case totalResults = "total_results"
        case currentPage = "current_page"
        case resultsPerPage = "results_per_page"
        case totalPages = "total_pages"
        case totalStores = "total_stores"
    }
}

struct OfferCategoryCount: Codable, Equatable {
    let categoryName: String
    let categoryKey: Int
    let offerCount: Int

    enum CodingKeys: String, CodingKey {
        case categoryName = "category_name"
        case categoryKey = "category_key"
        case offerCount = "offer_count"
    }
}

struct FeaturedOffer: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let image: FeaturedOfferImage?
    let offerTitle: String
    let redemptionUrl: String
    let promoCode: String
    let shortDescription: String
    let logo: String?
    let terms: String
    let expirationDate: String?
}

struct FeaturedOfferImage: Codable, Equatable {
    let url: String
}

struct FeaturedOffersResponse: Codable {
    let data: [FeaturedOfferDTO]?
}

struct FeaturedOfferDTO: Codable {
    let id: Int?
    let attributes: FeaturedOfferAttributes?
}

struct FeaturedOfferAttributes: Codable {
    let name: String?
    let offerTitle: String?
    let redemptionUrl: String?
    let promoCode: String?
    let shortDescription: String?
    let logo: String?
    let terms: String?
    let expirationDate: String?
    let image: FeaturedOfferImageData?
}

struct FeaturedOfferImageData: Codable {
    let data: FeaturedOfferImageAttributes?
}

struct FeaturedOfferImageAttributes: Codable {
    let attributes: FeaturedOfferImageURL?
}

struct FeaturedOfferImageURL: Codable {
    let url: String?
}
