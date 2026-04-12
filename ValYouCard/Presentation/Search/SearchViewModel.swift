import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var offers: [Offer] = []
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    @Published var selectedSubcategories: Set<Int> = []
    @Published var autocompleteResults: [String] = []
    @Published var offerCategoryCounts: [OfferCategoryCount] = []

    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var totalResults = 0
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?

    @Published var showFilters = false
    @Published var selectedDistance = "50mi"
    @Published var showOnline = true

    private let getAllOffersUseCase: GetAllOffersUseCaseProtocol
    private let getCategoriesUseCase: GetCategoriesUseCaseProtocol
    private let getAutocompleteUseCase: GetAutocompleteUseCaseProtocol

    private var searchTask: Task<Void, Never>?
    private var autocompleteTask: Task<Void, Never>?

    init(
        getAllOffersUseCase: GetAllOffersUseCaseProtocol,
        getCategoriesUseCase: GetCategoriesUseCaseProtocol,
        getAutocompleteUseCase: GetAutocompleteUseCaseProtocol,
        initialQuery: String = ""
    ) {
        self.getAllOffersUseCase = getAllOffersUseCase
        self.getCategoriesUseCase = getCategoriesUseCase
        self.getAutocompleteUseCase = getAutocompleteUseCase
        self.searchQuery = initialQuery
    }

    func loadInitialData() async {
        do {
            categories = try await getCategoriesUseCase.execute()
        } catch {
            // Categories are optional
        }

        await search()
    }

    func search() async {
        searchTask?.cancel()
        searchTask = Task {
            isLoading = true
            errorMessage = nil
            currentPage = 1
            offers = []

            await fetchOffers(page: 1)
            isLoading = false
        }
    }

    func loadNextPage() async {
        guard !isLoadingMore, currentPage < totalPages else { return }
        isLoadingMore = true
        let nextPage = currentPage + 1
        await fetchOffers(page: nextPage)
        isLoadingMore = false
    }

    func selectCategory(_ category: Category?) {
        selectedCategory = category
        selectedSubcategories.removeAll()
        Task { await search() }
    }

    func toggleSubcategory(_ key: Int) {
        if selectedSubcategories.contains(key) {
            selectedSubcategories.remove(key)
        } else {
            selectedSubcategories.insert(key)
        }
        Task { await search() }
    }

    func fetchAutocomplete() {
        autocompleteTask?.cancel()
        guard searchQuery.count >= 2 else {
            autocompleteResults = []
            return
        }

        autocompleteTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // debounce 300ms
            guard !Task.isCancelled else { return }

            do {
                autocompleteResults = try await getAutocompleteUseCase.execute(query: searchQuery)
            } catch {
                autocompleteResults = []
            }
        }
    }

    private func fetchOffers(page: Int) async {
        var categoryKeys: [Int] = []
        if let cat = selectedCategory {
            categoryKeys.append(cat.categoryKey)
        }
        categoryKeys.append(contentsOf: selectedSubcategories)

        let query = OffersQuery(
            page: page,
            query: searchQuery.isEmpty ? nil : searchQuery,
            categoryKeys: categoryKeys.isEmpty ? nil : categoryKeys,
            sort: "distance",
            online: showOnline ? "include" : nil,
            distance: selectedDistance
        )

        do {
            let response = try await getAllOffersUseCase.execute(query: query)

            if page == 1 {
                offers = response.offers
            } else {
                offers.append(contentsOf: response.offers)
            }

            currentPage = response.info.currentPage
            totalResults = response.info.totalResults
            totalPages = response.info.totalPages ?? max(1, (response.info.totalStores ?? response.info.totalResults) / response.info.resultsPerPage)
            offerCategoryCounts = response.offerCountInCategories ?? []
        } catch {
            if !Task.isCancelled {
                errorMessage = error.localizedDescription
            }
        }
    }
}
