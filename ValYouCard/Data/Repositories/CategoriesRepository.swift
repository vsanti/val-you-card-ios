import Foundation

final class CategoriesRepository: CategoriesRepositoryProtocol, @unchecked Sendable {
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func getCategories() async throws -> CategoriesResponse {
        let request = APIRequest(path: "/v1/categories", method: .get)
        return try await apiClient.request(
            baseURL: AppEnvironment.apiURL,
            request,
            defaultQueryItems: AppEnvironment.dealsAPIQueryItems
        )
    }
}
