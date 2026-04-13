import Foundation

protocol CategoriesRepositoryProtocol: Sendable {
    func getCategories() async throws -> CategoriesResponse
}
