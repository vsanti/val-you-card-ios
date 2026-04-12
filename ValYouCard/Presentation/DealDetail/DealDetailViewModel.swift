import Foundation

@MainActor
final class DealDetailViewModel: ObservableObject {
    @Published var offers: [Offer] = []
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var isLoading = false
    @Published var redeemingOfferKey: Int?
    @Published var expandedTerms: Set<Int> = []
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var redeemLink: String?

    let storeKey: String
    let storeName: String
    let locationKey: Int?

    private let getStoreOffersUseCase: GetStoreOffersUseCaseProtocol
    private let redeemOfferUseCase: RedeemOfferUseCaseProtocol

    init(
        storeKey: String,
        storeName: String,
        locationKey: Int?,
        getStoreOffersUseCase: GetStoreOffersUseCaseProtocol,
        redeemOfferUseCase: RedeemOfferUseCaseProtocol
    ) {
        self.storeKey = storeKey
        self.storeName = storeName
        self.locationKey = locationKey
        self.getStoreOffersUseCase = getStoreOffersUseCase
        self.redeemOfferUseCase = redeemOfferUseCase
    }

    func loadOffers(page: Int = 1) async {
        isLoading = true
        errorMessage = nil

        let query = StoreOffersQuery(
            storeKey: storeKey,
            page: page,
            locationKey: locationKey
        )

        do {
            let response = try await getStoreOffersUseCase.execute(query: query)
            offers = response.offers
            currentPage = response.info.currentPage
            let perPage = response.info.resultsPerPage
            totalPages = perPage > 0 ? max(1, Int(ceil(Double(response.info.totalResults) / Double(perPage)))) : 1
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func redeemOffer(_ offerKey: Int, user: User) async {
        redeemingOfferKey = offerKey
        errorMessage = nil
        successMessage = nil

        do {
            let link = try await redeemOfferUseCase.execute(offerKey: offerKey, user: user)
            redeemLink = link
            successMessage = "Offer redeemed successfully!"
        } catch {
            errorMessage = error.localizedDescription
        }

        redeemingOfferKey = nil
    }

    func toggleTerms(for offerKey: Int) {
        if expandedTerms.contains(offerKey) {
            expandedTerms.remove(offerKey)
        } else {
            expandedTerms.insert(offerKey)
        }
    }

    func goToPage(_ page: Int) async {
        guard page >= 1, page <= totalPages else { return }
        await loadOffers(page: page)
    }
}
