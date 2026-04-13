import SwiftUI

struct DealDetailView: View {
    @StateObject var viewModel: DealDetailViewModel
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    let storeName: String
    let logoUrl: String
    let storeDescription: String
    let physicalLocation: PhysicalLocation?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Store Header
                HStack(spacing: 12) {
                    AsyncImageView(url: logoUrl, width: 56, height: 56, cornerRadius: 8)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(storeName)
                            .font(.title3)
                            .fontWeight(.semibold)

                        if let address = physicalLocation?.formattedAddress {
                            Label(address, systemImage: "mappin.and.ellipse")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Description
                if !storeDescription.isEmpty {
                    Text(storeDescription.prefix(200) + (storeDescription.count > 200 ? "..." : ""))
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.darkGrey)
                }

                Divider()

                // Messages
                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error) {
                        viewModel.errorMessage = nil
                    }
                }

                if let success = viewModel.successMessage {
                    SuccessBanner(message: success)
                }

                // Offers
                Text("Deals & Offers")
                    .font(.headline)

                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .frame(height: 200)
                } else if viewModel.offers.isEmpty {
                    Text("No offers available")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.offers) { offer in
                            OfferRow(
                                offer: offer,
                                isExpanded: viewModel.expandedTerms.contains(offer.offerKey),
                                isRedeeming: viewModel.redeemingOfferKey == offer.offerKey,
                                onToggleTerms: {
                                    viewModel.toggleTerms(for: offer.offerKey)
                                },
                                onRedeem: {
                                    guard let user = auth.currentUser else { return }

                                    guard user.member, user.memberId != nil else {
                                        viewModel.errorMessage = "Active membership required to redeem offers"
                                        return
                                    }

                                    Task {
                                        await viewModel.redeemOffer(offer.offerKey, user: user)

                                        if let link = viewModel.redeemLink, let url = URL(string: link) {
                                            openURL(url)
                                        }
                                    }
                                }
                            )
                        }
                    }

                    // Pagination
                    if viewModel.totalPages > 1 {
                        HStack {
                            Spacer()
                            PaginationControl(
                                currentPage: viewModel.currentPage,
                                totalPages: viewModel.totalPages
                            ) { page in
                                Task { await viewModel.goToPage(page) }
                            }
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(storeName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
        }
        .task {
            if viewModel.offers.isEmpty {
                await viewModel.loadOffers()
            }
        }
    }
}

// MARK: - Offer Row

private struct OfferRow: View {
    let offer: Offer
    let isExpanded: Bool
    let isRedeeming: Bool
    let onToggleTerms: () -> Void
    let onRedeem: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(offer.title)
                        .font(.subheadline)

                    Button(action: onToggleTerms) {
                        HStack(spacing: 4) {
                            Text("Offer terms")
                                .font(.caption)
                            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                                .font(.caption2)
                        }
                        .foregroundStyle(AppTheme.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppTheme.blue, lineWidth: 1)
                        }
                    }
                }

                Spacer()

                Button(action: onRedeem) {
                    if isRedeeming {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Redeem")
                    }
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppTheme.orange)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .disabled(isRedeeming)
            }

            if isExpanded, let terms = offer.termsOfUse, !terms.isEmpty {
                Text(terms)
                    .font(.caption)
                    .foregroundStyle(AppTheme.darkGrey)
            }
        }
        .padding(12)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Pagination Control

private struct PaginationControl: View {
    let currentPage: Int
    let totalPages: Int
    let onPageChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button {
                onPageChange(currentPage - 1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.subheadline)
            }
            .disabled(currentPage <= 1)

            Text("\(currentPage) / \(totalPages)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                onPageChange(currentPage + 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.subheadline)
            }
            .disabled(currentPage >= totalPages)
        }
    }
}
