import Foundation

/// Dependency injection container using the composition root pattern.
@MainActor
final class DependencyContainer: ObservableObject {
    // MARK: - Shared Instances

    private let apiClient = APIClient()
    private let keychain = KeychainManager.shared

    // MARK: - Repositories

    lazy var authRepository: AuthRepositoryProtocol = AuthRepository(apiClient: apiClient, keychain: keychain)
    lazy var offersRepository: OffersRepositoryProtocol = OffersRepository(apiClient: apiClient)
    lazy var categoriesRepository: CategoriesRepositoryProtocol = CategoriesRepository(apiClient: apiClient)
    lazy var redeemRepository: RedeemRepositoryProtocol = RedeemRepository(apiClient: apiClient)
    lazy var paymentRepository: PaymentRepositoryProtocol = PaymentRepository(apiClient: apiClient, keychain: keychain)

    // MARK: - Use Cases

    var signInUseCase: SignInUseCaseProtocol { SignInUseCase(repository: authRepository) }
    var signUpUseCase: SignUpUseCaseProtocol { SignUpUseCase(repository: authRepository) }
    var forgotPasswordUseCase: ForgotPasswordUseCaseProtocol { ForgotPasswordUseCase(repository: authRepository) }
    var getProfileUseCase: GetProfileUseCaseProtocol { GetProfileUseCase(repository: authRepository) }
    var changePasswordUseCase: ChangePasswordUseCaseProtocol { ChangePasswordUseCase(repository: authRepository) }

    var getAllOffersUseCase: GetAllOffersUseCaseProtocol { GetAllOffersUseCase(repository: offersRepository) }
    var getStoreOffersUseCase: GetStoreOffersUseCaseProtocol { GetStoreOffersUseCase(repository: offersRepository) }
    var getNewOffersUseCase: GetNewOffersUseCaseProtocol { GetNewOffersUseCase(repository: offersRepository) }
    var getFeaturedOffersUseCase: GetFeaturedOffersUseCaseProtocol { GetFeaturedOffersUseCase(repository: offersRepository) }
    var getAutocompleteUseCase: GetAutocompleteUseCaseProtocol { GetAutocompleteUseCase(repository: offersRepository) }
    var redeemOfferUseCase: RedeemOfferUseCaseProtocol { RedeemOfferUseCase(redeemRepository: redeemRepository) }

    var getCategoriesUseCase: GetCategoriesUseCaseProtocol { GetCategoriesUseCase(repository: categoriesRepository) }

    // MARK: - View Models

    func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(
            signInUseCase: signInUseCase,
            signUpUseCase: signUpUseCase,
            forgotPasswordUseCase: forgotPasswordUseCase,
            getProfileUseCase: getProfileUseCase,
            authRepository: authRepository
        )
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            getFeaturedOffersUseCase: getFeaturedOffersUseCase,
            getNewOffersUseCase: getNewOffersUseCase,
            getCategoriesUseCase: getCategoriesUseCase
        )
    }

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(
            getAllOffersUseCase: getAllOffersUseCase,
            getCategoriesUseCase: getCategoriesUseCase,
            getAutocompleteUseCase: getAutocompleteUseCase
        )
    }

    func makeDealDetailViewModel(storeKey: String, storeName: String, locationKey: Int?) -> DealDetailViewModel {
        DealDetailViewModel(
            storeKey: storeKey,
            storeName: storeName,
            locationKey: locationKey,
            getStoreOffersUseCase: getStoreOffersUseCase,
            redeemOfferUseCase: redeemOfferUseCase
        )
    }

    func makeAccountViewModel() -> AccountViewModel {
        AccountViewModel(
            getProfileUseCase: getProfileUseCase,
            changePasswordUseCase: changePasswordUseCase,
            paymentRepository: paymentRepository,
            authRepository: authRepository
        )
    }

    func makeMembershipViewModel() -> MembershipViewModel {
        MembershipViewModel(paymentRepository: paymentRepository)
    }
}
