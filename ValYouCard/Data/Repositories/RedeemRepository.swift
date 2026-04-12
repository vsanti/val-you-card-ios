import Foundation

final class RedeemRepository: RedeemRepositoryProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func redeemOffer(offerKey: Int, firstName: String, lastName: String, memberId: String) async throws -> RedeemResponse {
        let items = [
            URLQueryItem(name: "first_name", value: firstName),
            URLQueryItem(name: "last_name", value: lastName),
            URLQueryItem(name: "member_key", value: memberId),
        ]

        let request = APIRequest(path: "/v1/redeem/\(offerKey)", method: .get, queryItems: items)
        return try await apiClient.request(
            baseURL: AppEnvironment.redeemAPIURL,
            request,
            defaultQueryItems: AppEnvironment.dealsAPIQueryItems
        )
    }

    func redeemOfferMethod(offerKey: Int, firstName: String, lastName: String, memberId: String, method: String) async throws -> RedeemResponse {
        let items = [
            URLQueryItem(name: "first_name", value: firstName),
            URLQueryItem(name: "last_name", value: lastName),
            URLQueryItem(name: "member_key", value: memberId),
        ]

        let request = APIRequest(path: "/v1/redeem/\(offerKey)/\(method)", method: .get, queryItems: items)
        return try await apiClient.request(
            baseURL: AppEnvironment.redeemAPIURL,
            request,
            defaultQueryItems: AppEnvironment.dealsAPIQueryItems
        )
    }
}
