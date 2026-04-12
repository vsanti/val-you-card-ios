import Foundation

protocol GetAllOffersUseCaseProtocol {
    func execute(query: OffersQuery) async throws -> OffersResponse
}

protocol GetStoreOffersUseCaseProtocol {
    func execute(query: StoreOffersQuery) async throws -> OffersResponse
}

protocol GetNewOffersUseCaseProtocol {
    func execute() async throws -> OffersResponse
}

protocol GetFeaturedOffersUseCaseProtocol {
    func execute() async throws -> [FeaturedOffer]
}

protocol GetAutocompleteUseCaseProtocol {
    func execute(query: String) async throws -> [String]
}

protocol RedeemOfferUseCaseProtocol {
    func execute(offerKey: Int, user: User) async throws -> String?
}

// MARK: - Implementations

struct GetAllOffersUseCase: GetAllOffersUseCaseProtocol {
    let repository: OffersRepositoryProtocol

    func execute(query: OffersQuery) async throws -> OffersResponse {
        try await repository.getAllOffers(query: query)
    }
}

struct GetStoreOffersUseCase: GetStoreOffersUseCaseProtocol {
    let repository: OffersRepositoryProtocol

    func execute(query: StoreOffersQuery) async throws -> OffersResponse {
        try await repository.getStoreOffers(query: query)
    }
}

struct GetNewOffersUseCase: GetNewOffersUseCaseProtocol {
    let repository: OffersRepositoryProtocol

    func execute() async throws -> OffersResponse {
        try await repository.getNewOffers()
    }
}

struct GetFeaturedOffersUseCase: GetFeaturedOffersUseCaseProtocol {
    let repository: OffersRepositoryProtocol

    func execute() async throws -> [FeaturedOffer] {
        try await repository.getFeaturedOffers()
    }
}

struct GetAutocompleteUseCase: GetAutocompleteUseCaseProtocol {
    let repository: OffersRepositoryProtocol

    func execute(query: String) async throws -> [String] {
        try await repository.getAutocomplete(query: query)
    }
}

struct RedeemOfferUseCase: RedeemOfferUseCaseProtocol {
    let redeemRepository: RedeemRepositoryProtocol

    func execute(offerKey: Int, user: User) async throws -> String? {
        let nameParts = (user.name ?? "").split(separator: " ")
        let firstName = String(nameParts.first ?? "")
        let lastName = nameParts.count > 1 ? String(nameParts.last!) : ""
        let memberId = user.memberId ?? ""

        let initial = try await redeemRepository.redeemOffer(
            offerKey: offerKey,
            firstName: firstName,
            lastName: lastName,
            memberId: memberId
        )

        let priorityOrder: [String: Int] = [
            "instore_print": 1,
            "instore": 2,
            "link": 3,
        ]

        guard let links = initial.links else {
            throw AppError.redemptionFailed("No redemption methods available")
        }

        let preferredLink = links
            .filter { ["instore_print", "instore", "link"].contains($0.rel) }
            .sorted { (priorityOrder[$0.rel] ?? 99) < (priorityOrder[$1.rel] ?? 99) }
            .first

        guard let method = preferredLink else {
            throw AppError.redemptionFailed("No valid redemption method found")
        }

        let final = try await redeemRepository.redeemOfferMethod(
            offerKey: offerKey,
            firstName: firstName,
            lastName: lastName,
            memberId: memberId,
            method: method.rel
        )

        return final.details?.link
    }
}
