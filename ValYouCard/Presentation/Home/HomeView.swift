import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @EnvironmentObject var auth: AuthViewModel
    @State private var searchText = ""
    @State private var navigateToSearch = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Banner
                HeroBanner(searchText: $searchText) {
                    navigateToSearch = true
                }

                VStack(spacing: 32) {
                    // Featured Deals
                    if !viewModel.featuredOffers.isEmpty {
                        FeaturedDealsSection(offers: viewModel.featuredOffers)
                    }

                    // Categories
                    if !viewModel.categories.isEmpty {
                        CategoriesSection(categories: viewModel.categories)
                    }

                    // Call to Action
                    CallToActionCard()

                    // New Deals
                    if !viewModel.newOffers.isEmpty {
                        NewDealsSection(offers: viewModel.newOffers)
                    }

                    // Bottom CTA
                    CallToActionCard()
                }
                .padding(.top, 24)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Val-You Card")
                    .font(.headline)
                    .foregroundStyle(AppTheme.orange)
            }
        }
        .refreshable {
            await viewModel.loadData()
        }
        .task {
            if viewModel.newOffers.isEmpty {
                await viewModel.loadData()
            }
        }
        .navigationDestination(isPresented: $navigateToSearch) {
            SearchView(viewModel: SearchViewModel(
                getAllOffersUseCase: GetAllOffersUseCase(repository: OffersRepository()),
                getCategoriesUseCase: GetCategoriesUseCase(repository: CategoriesRepository()),
                getAutocompleteUseCase: GetAutocompleteUseCase(repository: OffersRepository()),
                initialQuery: searchText
            ))
        }
        .overlay {
            if viewModel.isLoading && viewModel.newOffers.isEmpty {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }
}

// MARK: - Hero Banner

private struct HeroBanner: View {
    @Binding var searchText: String
    var onSearch: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            // Gradient background
            AppTheme.heroGradient
                .frame(height: 220)
                .clipShape(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                )
                .padding(.horizontal, 16)

            // Content
            VStack(alignment: .leading, spacing: 12) {
                Text("Save More with\nEvery Purchase!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                HStack(spacing: 16) {
                    Label("Thousands of Deals", systemImage: "checkmark")
                    Label("Exclusive Discounts", systemImage: "checkmark")
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.9))

                Spacer(minLength: 32)
            }
            .padding(.horizontal, 32)
            .padding(.top, 24)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Search bar overlapping
            SearchBar(text: $searchText, onSubmit: onSearch)
                .padding(.horizontal, 24)
                .offset(y: 20)
        }
        .padding(.bottom, 20)
    }
}

// MARK: - Featured Deals Section

private struct FeaturedDealsSection: View {
    let offers: [FeaturedOffer]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Featured Deals")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(offers) { offer in
                        FeaturedDealCard(offer: offer)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct FeaturedDealCard: View {
    let offer: FeaturedOffer

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageUrl = offer.image?.url {
                AsyncImageView(url: imageUrl, width: 260, height: 140, cornerRadius: 12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.cardBackground)
                    .frame(width: 260, height: 140)
                    .overlay {
                        Image(systemName: "tag.fill")
                            .font(.largeTitle)
                            .foregroundStyle(AppTheme.grey)
                    }
            }

            Text(offer.offerTitle)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)

            Text(offer.shortDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(width: 260)
    }
}

// MARK: - Categories Section

private struct CategoriesSection: View {
    let categories: [Category]

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    private let categoryIcons: [String: String] = [
        "Dining": "fork.knife",
        "Shopping": "bag.fill",
        "Travel": "airplane",
        "Entertainment": "film.fill",
        "Health & Beauty": "heart.fill",
        "Services": "wrench.and.screwdriver.fill",
        "Automotive": "car.fill",
        "Education": "book.fill",
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Categories")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(categories.prefix(9)) { category in
                    CategoryCell(
                        name: category.categoryName,
                        icon: categoryIcons[category.categoryName] ?? "tag.fill"
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct CategoryCell: View {
    let name: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(AppTheme.orange)
                .frame(width: 44, height: 44)
                .background(AppTheme.orange.opacity(0.1))
                .clipShape(Circle())

            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - New Deals Section

private struct NewDealsSection: View {
    let offers: [Offer]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New Deals")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            LazyVStack(spacing: 12) {
                ForEach(offers.prefix(10)) { offer in
                    OfferCardView(offer: offer)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Call to Action

private struct CallToActionCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Ready to Start Saving?")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text("Join thousands of members who are already saving money on every purchase.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(AppTheme.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}
