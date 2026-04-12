import Foundation

struct Store: Identifiable, Codable, Equatable {
    var id: Int { storeKey }

    let storeKey: Int
    let name: String
    let logoUrl: String
    let description: String
    let storeCategories: [StoreCategory]
    let activeOfferCount: Int

    enum CodingKeys: String, CodingKey {
        case storeKey = "store_key"
        case name
        case logoUrl = "logo_url"
        case description
        case storeCategories = "store_categories"
        case activeOfferCount = "active_offer_count"
    }
}

struct StoreCategory: Codable, Equatable {
    let categoryName: String
    let categoryKey: Int
    let categoryParentKey: Int
    let categoryParentName: String
    let categoryType: String

    enum CodingKeys: String, CodingKey {
        case categoryName = "category_name"
        case categoryKey = "category_key"
        case categoryParentKey = "category_parent_key"
        case categoryParentName = "category_parent_name"
        case categoryType = "category_type"
    }
}

struct StoresResponse: Codable {
    let stores: [Store]
    let info: StoresInfo
}

struct StoresInfo: Codable {
    let totalResults: Int
    let currentPage: Int
    let totalPages: Int
    let resultsPerPage: Int

    enum CodingKeys: String, CodingKey {
        case totalResults = "total_results"
        case currentPage = "current_page"
        case totalPages = "total_pages"
        case resultsPerPage = "results_per_page"
    }
}
