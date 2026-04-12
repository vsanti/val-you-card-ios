import Foundation

@MainActor
final class AccountViewModel: ObservableObject {
    @Published var userProfile: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // Change password
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var confirmNewPassword = ""
    @Published var isChangingPassword = false

    private let getProfileUseCase: GetProfileUseCaseProtocol
    private let changePasswordUseCase: ChangePasswordUseCaseProtocol
    private let paymentRepository: PaymentRepositoryProtocol
    private let authRepository: AuthRepositoryProtocol

    init(
        getProfileUseCase: GetProfileUseCaseProtocol,
        changePasswordUseCase: ChangePasswordUseCaseProtocol,
        paymentRepository: PaymentRepositoryProtocol,
        authRepository: AuthRepositoryProtocol
    ) {
        self.getProfileUseCase = getProfileUseCase
        self.changePasswordUseCase = changePasswordUseCase
        self.paymentRepository = paymentRepository
        self.authRepository = authRepository
    }

    func loadProfile() async {
        isLoading = true
        do {
            userProfile = try await getProfileUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func changePassword() async {
        guard !currentPassword.isEmpty, !newPassword.isEmpty else {
            errorMessage = "Please fill in all password fields"
            return
        }
        guard newPassword == confirmNewPassword else {
            errorMessage = "New passwords do not match"
            return
        }
        guard newPassword.count >= 6 else {
            errorMessage = "New password must be at least 6 characters"
            return
        }

        isChangingPassword = true
        errorMessage = nil
        successMessage = nil

        do {
            let message = try await changePasswordUseCase.execute(
                currentPassword: currentPassword,
                newPassword: newPassword
            )
            successMessage = message
            currentPassword = ""
            newPassword = ""
            confirmNewPassword = ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isChangingPassword = false
    }

    func getManageSubscriptionURL() async -> URL? {
        guard let customerId = userProfile?.stripeCustomerId else { return nil }
        do {
            let urlString = try await paymentRepository.createPortalSession(customerId: customerId)
            return URL(string: urlString)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
