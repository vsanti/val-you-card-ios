import SwiftUI

struct MembershipUpgradeView: View {
    @StateObject var viewModel: MembershipViewModel
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Upgrade Your Membership")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Choose a plan to unlock exclusive benefits")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)

                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error) {
                        viewModel.errorMessage = nil
                    }
                }

                // Plans
                VStack(spacing: 16) {
                    PlanCard(
                        plan: .yearly,
                        isSelected: viewModel.selectedPlan == .yearly
                    ) {
                        viewModel.selectedPlan = .yearly
                    }

                    PlanCard(
                        plan: .monthly,
                        isSelected: viewModel.selectedPlan == .monthly
                    ) {
                        viewModel.selectedPlan = .monthly
                    }
                }

                // Selection confirmation
                if let plan = viewModel.selectedPlan {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("\(plan.displayName) selected")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.green)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // Checkout button
                PrimaryButton(
                    title: viewModel.selectedPlan != nil
                        ? "Upgrade to \(viewModel.selectedPlan!.displayName)"
                        : "Select a Plan",
                    isLoading: viewModel.isLoading,
                    isDisabled: viewModel.selectedPlan == nil
                ) {
                    guard let user = auth.currentUser else { return }
                    Task {
                        await viewModel.startCheckout(
                            userId: user.id,
                            email: user.email,
                            name: user.name ?? ""
                        )
                        if let url = viewModel.checkoutURL {
                            openURL(url)
                        }
                    }
                }

                // Benefits
                BenefitsCard()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .navigationTitle("Membership")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Plan Card

private struct PlanCard: View {
    let plan: MembershipViewModel.MembershipPlan
    let isSelected: Bool
    let onSelect: () -> Void

    private var accentColor: Color {
        plan == .yearly ? AppTheme.orange : AppTheme.blue
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(plan.price)
                                .font(.title)
                                .fontWeight(.bold)

                            if let original = plan.originalPrice {
                                Text(original)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .strikethrough()
                            }
                        }
                        Text(plan.period)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if let savings = plan.savingsNote {
                            Text(savings)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(accentColor)
                        }
                    }

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(isSelected ? accentColor : Color(.systemGray3))
                }

                VStack(alignment: .leading, spacing: 6) {
                    BenefitRow(text: "Redeem All Discounts")
                    BenefitRow(text: "Redeem Online, In-Person or by Call")
                    BenefitRow(text: plan == .yearly ? "Annual automatic renewal" : "Monthly automatic renewal")
                }

                if plan == .yearly {
                    Text("Save $40 vs monthly")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.green)
                } else {
                    Text("Flexible monthly billing")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.blue)
                }
            }
            .padding(16)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? accentColor : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            }
            .shadow(color: isSelected ? accentColor.opacity(0.2) : .clear, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

private struct BenefitRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark")
                .font(.caption2)
                .foregroundStyle(.green)
            Text(text)
                .font(.subheadline)
        }
    }
}

// MARK: - Benefits Card

private struct BenefitsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Membership Benefits")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                BenefitRow(text: "Access to exclusive discounts and deals")
                BenefitRow(text: "Member ID for in-store redemption")
                BenefitRow(text: "Priority customer support")
                BenefitRow(text: "Early access to new offers")
                BenefitRow(text: "Automatic renewal (cancel anytime)")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}
