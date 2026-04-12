import Foundation

struct Category: Identifiable, Codable, Equatable, Hashable {
    var id: Int { categoryKey }

    let categoryName: String
    let categoryKey: Int
    let subcategories: [Category]?

    enum CodingKeys: String, CodingKey {
        case categoryName = "category_name"
        case categoryKey = "category_key"
        case subcategories
    }
}

struct CategoriesResponse: Codable {
    let categories: [Category]
    let info: CategoriesInfo
}

struct CategoriesInfo: Codable {
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
