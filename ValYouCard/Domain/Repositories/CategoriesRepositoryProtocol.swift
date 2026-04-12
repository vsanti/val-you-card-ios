import Foundation

protocol CategoriesRepositoryProtocol {
    func getCategories() async throws -> CategoriesResponse
}
