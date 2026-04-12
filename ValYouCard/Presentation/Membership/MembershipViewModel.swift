import Foundation

@MainActor
final class MembershipViewModel: ObservableObject {
    @Published var selectedPlan: MembershipPlan?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var checkoutURL: URL?

    enum MembershipPlan: String, CaseIterable {
        case yearly
        case monthly

        var displayName: String {
            switch self {
            case .yearly: return "Yearly Plan"
            case .monthly: return "Monthly Plan"
            }
        }

        var price: String {
            switch self {
            case .yearly: return "$20"
            case .monthly: return "$5"
            }
        }

        var period: String {
            switch self {
            case .yearly: return "per year"
            case .monthly: return "per month"
            }
        }

        var originalPrice: String? {
            switch self {
            case .yearly: return "$50"
            case .monthly: return nil
            }
        }

        var savingsNote: String? {
            switch self {
            case .yearly: return "Save $30 - Limited Time Offer!"
            case .monthly: return nil
            }
        }
    }

    private let paymentRepository: PaymentRepositoryProtocol

    init(paymentRepository: PaymentRepositoryProtocol) {
        self.paymentRepository = paymentRepository
    }

    func startCheckout(userId: Int, email: String, name: String) async {
        guard let plan = selectedPlan else {
            errorMessage = "Please select a plan"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let session = try await paymentRepository.createCheckoutSession(
                membershipType: plan.rawValue,
                userId: userId,
                returnUrl: "valyoucard://membership/success"
            )
            checkoutURL = URL(string: session.url)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
