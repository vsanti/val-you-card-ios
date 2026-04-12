import Foundation

protocol GetCategoriesUseCaseProtocol {
    func execute() async throws -> [Category]
}

struct GetCategoriesUseCase: GetCategoriesUseCaseProtocol {
    let repository: CategoriesRepositoryProtocol

    func execute() async throws -> [Category] {
        let response = try await repository.getCategories()
        return response.categories
    }
}
