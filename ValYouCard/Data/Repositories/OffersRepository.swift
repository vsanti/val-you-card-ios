import Foundation

final class OffersRepository: OffersRepositoryProtocol, @unchecked Sendable {
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func getAllOffers(query: OffersQuery) async throws -> OffersResponse {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(query.page)),
            URLQueryItem(name: "sort", value: query.sort),
            URLQueryItem(name: "distance", value: query.distance),
            URLQueryItem(name: "rollup", value: "stores"),
            URLQueryItem(name: "fuzziness", value: "true"),
            URLQueryItem(name: "suggestion", value: "true"),
            URLQueryItem(name: "aggregations", value: "categories,stores"),
        ]

        if let keys = query.categoryKeys, !keys.isEmpty {
            items.append(URLQueryItem(name: "category_key", value: keys.map(String.init).joined(separator: ",")))
        }
        if let q = query.query, !q.isEmpty {
            items.append(URLQueryItem(name: "query", value: q))
        }
        if let lat = query.lat, let lon = query.lon {
            items.append(URLQueryItem(name: "lat", value: String(lat)))
            items.append(URLQueryItem(name: "lon", value: String(lon)))
        } else if let postalCode = query.postalCode {
            items.append(URLQueryItem(name: "postal_code", value: postalCode))
        }
        if let online = query.online {
            items.append(URLQueryItem(name: "online", value: online))
        }
        if let offerType = query.offerType {
            items.append(URLQueryItem(name: "offer_type", value: offerType))
        }

        let request = APIRequest(path: "/v1/offers", method: .get, queryItems: items)
        return try await apiClient.request(
            baseURL: AppEnvironment.apiURL,
            request,
            defaultQueryItems: AppEnvironment.dealsAPIQueryItems
        )
    }

    func getStoreOffers(query: StoreOffersQuery) async throws -> OffersResponse {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "store_key", value: query.storeKey),
            URLQueryItem(name: "page", value: String(query.page)),
        ]
        if let locationKey = query.locationKey {
            items.append(URLQueryItem(name: "location_key", value: String(locationKey)))
        }

        let request = APIRequest(path: "/v1/offers", method: .get, queryItems: items)
        return try await apiClient.request(
            baseURL: AppEnvironment.apiURL,
            request,
            defaultQueryItems: AppEnvironment.dealsAPIQueryItems
        )
    }

    func getNewOffers() async throws -> OffersResponse {
        let items = [
            URLQueryItem(name: "offer_type", value: "new"),
            URLQueryItem(name: "rollup", value: "stores"),
        ]
        let request = APIRequest(path: "/v1/offers", method: .get, queryItems: items)
        return try await apiClient.request(
            baseURL: AppEnvironment.apiURL,
            request,
            defaultQueryItems: AppEnvironment.dealsAPIQueryItems
        )
    }

    func getFeaturedOffers() async throws -> [FeaturedOffer] {
        let request = APIRequest(
            path: "/featured-offers",
            method: .get,
            queryItems: [URLQueryItem(name: "populate", value: "*")]
        )

        let response: FeaturedOffersResponse = try await apiClient.request(
            baseURL: AppEnvironment.strapiURL,
            request
        )

        return response.data?.compactMap { dto -> FeaturedOffer? in
            guard let attrs = dto.attributes else { return nil }
            return FeaturedOffer(
                id: String(dto.id ?? 0),
                name: attrs.name ?? "",
                image: attrs.image?.data?.attributes?.url.map { FeaturedOfferImage(url: $0) },
                offerTitle: attrs.offerTitle ?? "",
                redemptionUrl: attrs.redemptionUrl ?? "",
                promoCode: attrs.promoCode ?? "",
                shortDescription: attrs.shortDescription ?? "",
                logo: attrs.logo,
                terms: attrs.terms ?? "",
                expirationDate: attrs.expirationDate
            )
        } ?? []
    }

    func getAutocomplete(query: String) async throws -> [String] {
        struct AutocompleteResponse: Decodable {
            let results: [AutocompleteResult]?
        }
        struct AutocompleteResult: Decodable {
            let name: String?
        }

        let items = [URLQueryItem(name: "query", value: query)]
        let request = APIRequest(path: "/v1/autocomplete", method: .get, queryItems: items)

        do {
            let response: AutocompleteResponse = try await apiClient.request(
                baseURL: AppEnvironment.apiURL,
                request,
                defaultQueryItems: AppEnvironment.dealsAPIQueryItems
            )
            return response.results?.compactMap(\.name) ?? []
        } catch {
            // Fallback to stores search
            let storeItems = [URLQueryItem(name: "starts_with", value: query)]
            let storeRequest = APIRequest(path: "/v1/stores", method: .get, queryItems: storeItems)

            let response: StoresResponse = try await apiClient.request(
                baseURL: AppEnvironment.apiURL,
                storeRequest,
                defaultQueryItems: AppEnvironment.dealsAPIQueryItems
            )
            return Array(response.stores.prefix(8).map(\.name))
        }
    }
}
