import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var featuredOffers: [FeaturedOffer] = []
    @Published var newOffers: [Offer] = []
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let getFeaturedOffersUseCase: GetFeaturedOffersUseCaseProtocol
    private let getNewOffersUseCase: GetNewOffersUseCaseProtocol
    private let getCategoriesUseCase: GetCategoriesUseCaseProtocol

    init(
        getFeaturedOffersUseCase: GetFeaturedOffersUseCaseProtocol,
        getNewOffersUseCase: GetNewOffersUseCaseProtocol,
        getCategoriesUseCase: GetCategoriesUseCaseProtocol
    ) {
        self.getFeaturedOffersUseCase = getFeaturedOffersUseCase
        self.getNewOffersUseCase = getNewOffersUseCase
        self.getCategoriesUseCase = getCategoriesUseCase
    }

    func loadData() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        async let featured = getFeaturedOffersUseCase.execute()
        async let newOffs = getNewOffersUseCase.execute()
        async let cats = getCategoriesUseCase.execute()

        do {
            featuredOffers = try await featured
        } catch {
            // Featured offers are optional, don't fail the whole screen
        }

        do {
            let response = try await newOffs
            newOffers = response.offers
        } catch {
            errorMessage = error.localizedDescription
        }

        do {
            categories = try await cats
        } catch {
            // Categories are optional for the home screen
        }

        isLoading = false
    }
}
