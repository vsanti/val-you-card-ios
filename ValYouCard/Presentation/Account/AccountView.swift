import SwiftUI

struct AccountView: View {
    @StateObject var viewModel: AccountViewModel
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.openURL) private var openURL
    @State private var showChangePassword = false

    var body: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.userProfile == nil {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
            } else if let user = viewModel.userProfile ?? auth.currentUser {
                VStack(spacing: 20) {
                    // Profile Header
                    ProfileHeader(user: user) {
                        Task { await auth.signOut() }
                    }

                    // Membership Status
                    MembershipStatusCard(user: user)

                    // Member ID Card
                    if user.member, let memberId = user.memberId {
                        MemberIdCardView(memberId: memberId)
                            .padding(.horizontal)
                    }

                    // Membership Expiration
                    if user.member, let end = user.membershipEnd {
                        MembershipExpirationBanner(expirationDate: end)
                    }

                    // Upgrade CTA (for non-members)
                    if !user.member {
                        UpgradeCTA()
                    }

                    // Account Information
                    AccountInfoSection(user: user)

                    // Payment Management
                    if user.member, user.stripeCustomerId != nil {
                        PaymentManagementSection {
                            Task {
                                if let url = await viewModel.getManageSubscriptionURL() {
                                    openURL(url)
                                }
                            }
                        }
                    }

                    // Change Password
                    ChangePasswordSection(
                        viewModel: viewModel,
                        showChangePassword: $showChangePassword
                    )

                    // Messages
                    if let error = viewModel.errorMessage {
                        ErrorBanner(message: error) {
                            viewModel.errorMessage = nil
                        }
                    }

                    if let success = viewModel.successMessage {
                        SuccessBanner(message: success)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("My Account")
        .refreshable {
            await viewModel.loadProfile()
        }
        .task {
            await viewModel.loadProfile()
        }
    }
}

// MARK: - Profile Header

private struct ProfileHeader: View {
    let user: User
    let onSignOut: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Avatar
            Text(String((user.name ?? "U").prefix(1)).uppercased())
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(AppTheme.orange)
                .clipShape(Circle())

            Text(user.name ?? "User")
                .font(.title3)
                .fontWeight(.semibold)

            Text(user.email)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: onSignOut) {
                Text("Sign Out")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

// MARK: - Membership Status

private struct MembershipStatusCard: View {
    let user: User

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(user.member ? .green : Color(.systemGray4))
                    .frame(width: 10, height: 10)
                Text(user.member ? "Active Member" : "Free User")
                    .fontWeight(.medium)
            }

            Spacer()

            if user.member {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Premium Access")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.green)
                    if let type = user.membershipType {
                        Text(type == "yearly" ? "Yearly Plan" : "Monthly Plan")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Membership Expiration

private struct MembershipExpirationBanner: View {
    let expirationDate: Date

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.fill")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("Membership Expires")
                    .font(.caption)
                    .fontWeight(.medium)
                Text(expirationDate, style: .date)
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        }
    }
}

// MARK: - Upgrade CTA

private struct UpgradeCTA: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Upgrade to premium membership to access exclusive discounts and deals")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            NavigationLink {
                MembershipUpgradeView(viewModel: MembershipViewModel(
                    paymentRepository: PaymentRepository()
                ))
            } label: {
                Text("Get Membership")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppTheme.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(AppTheme.orange.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Account Info

private struct AccountInfoSection: View {
    let user: User

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Account Information")
                .font(.headline)
                .padding(.bottom, 12)

            InfoRow(label: "User ID", value: String(user.id))
            InfoRow(label: "Email", value: user.email)
            InfoRow(label: "Membership Type", value: user.member
                    ? (user.membershipType == "yearly" ? "Yearly Plan" : "Monthly Plan")
                    : "Free User")

            if let paymentId = user.stripePaymentId {
                InfoRow(label: "Payment ID", value: paymentId, isMonospace: true)
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

private struct InfoRow: View {
    let label: String
    let value: String
    var isMonospace: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(isMonospace ? .system(.caption, design: .monospaced) : .subheadline)
                .lineLimit(1)
        }
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}

// MARK: - Payment Management

private struct PaymentManagementSection: View {
    let onManage: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Methods")
                .font(.headline)

            Button(action: onManage) {
                HStack {
                    Image(systemName: "creditcard.fill")
                    Text("Manage Subscription")
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                }
                .foregroundStyle(AppTheme.blue)
                .padding()
                .background(AppTheme.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

// MARK: - Change Password

private struct ChangePasswordSection: View {
    @ObservedObject var viewModel: AccountViewModel
    @Binding var showChangePassword: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                showChangePassword.toggle()
            } label: {
                HStack {
                    Text("Change Password")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: showChangePassword ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }

            if showChangePassword {
                VStack(spacing: 12) {
                    SecureField("Current Password", text: $viewModel.currentPassword)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    SecureField("New Password", text: $viewModel.newPassword)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    SecureField("Confirm New Password", text: $viewModel.confirmNewPassword)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    PrimaryButton(
                        title: "Update Password",
                        isLoading: viewModel.isChangingPassword
                    ) {
                        Task { await viewModel.changePassword() }
                    }
                }
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}
