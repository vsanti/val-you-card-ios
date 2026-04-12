import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel
    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var auth: AuthViewModel
    @State private var selectedOffer: Offer?

    var body: some View {
        VStack(spacing: 0) {
            // Search Header
            VStack(spacing: 12) {
                SearchBar(text: $viewModel.searchQuery) {
                    viewModel.autocompleteResults = []
                    Task { await viewModel.search() }
                }
                .onChange(of: viewModel.searchQuery) { _, _ in
                    viewModel.fetchAutocomplete()
                }

                // Filter pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterPill(
                            title: "Filters",
                            icon: "slider.horizontal.3",
                            isActive: viewModel.selectedCategory != nil
                        ) {
                            viewModel.showFilters = true
                        }

                        if let cat = viewModel.selectedCategory {
                            FilterPill(title: cat.categoryName, isActive: true) {
                                viewModel.selectCategory(nil)
                            }
                        }

                        FilterPill(
                            title: viewModel.selectedDistance,
                            icon: "location.fill",
                            isActive: false
                        ) {
                            viewModel.showFilters = true
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)

            // Autocomplete overlay
            if !viewModel.autocompleteResults.isEmpty {
                AutocompleteList(
                    results: viewModel.autocompleteResults,
                    onSelect: { result in
                        viewModel.searchQuery = result
                        viewModel.autocompleteResults = []
                        Task { await viewModel.search() }
                    }
                )
            }

            // Results
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Spacer()
            } else if viewModel.offers.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(AppTheme.grey)
                    Text("No deals found")
                        .font(.headline)
                    Text("Try adjusting your search or filters")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            } else {
                // Results count
                HStack {
                    Text("\(viewModel.totalResults) results")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Offers list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.offers) { offer in
                            Button {
                                selectedOffer = offer
                            } label: {
                                OfferCardView(offer: offer)
                            }
                            .buttonStyle(.plain)
                            .onAppear {
                                if offer == viewModel.offers.last {
                                    Task { await viewModel.loadNextPage() }
                                }
                            }
                        }

                        if viewModel.isLoadingMore {
                            ProgressView()
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Browse Deals")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.offers.isEmpty {
                await viewModel.loadInitialData()
            }
        }
        .sheet(isPresented: $viewModel.showFilters) {
            FilterSheet(viewModel: viewModel)
        }
        .sheet(item: $selectedOffer) { offer in
            NavigationStack {
                DealDetailView(
                    viewModel: container.makeDealDetailViewModel(
                        storeKey: String(offer.offerStore.storeKey),
                        storeName: offer.offerStore.name,
                        locationKey: offer.offerStore.physicalLocation.locationKey
                    ),
                    storeName: offer.offerStore.name,
                    logoUrl: offer.logoUrl,
                    storeDescription: offer.offerStore.description,
                    physicalLocation: offer.offerStore.physicalLocation
                )
            }
            .presentationDetents([.large])
        }
    }
}

// MARK: - Filter Pill

private struct FilterPill: View {
    let title: String
    var icon: String? = nil
    var isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption2)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isActive ? AppTheme.orange.opacity(0.1) : Color(.systemGray6))
            .foregroundStyle(isActive ? AppTheme.orange : .primary)
            .clipShape(Capsule())
            .overlay {
                if isActive {
                    Capsule().stroke(AppTheme.orange, lineWidth: 1)
                }
            }
        }
    }
}

// MARK: - Autocomplete List

private struct AutocompleteList: View {
    let results: [String]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(results.prefix(6), id: \.self) { result in
                Button {
                    onSelect(result)
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        Text(result)
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                Divider().padding(.leading)
            }
        }
        .background(.regularMaterial)
    }
}

// MARK: - Filter Sheet

private struct FilterSheet: View {
    @ObservedObject var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss

    let distances = ["10mi", "25mi", "50mi", "100mi", "200mi"]

    var body: some View {
        NavigationStack {
            List {
                // Distance
                Section("Distance") {
                    ForEach(distances, id: \.self) { distance in
                        Button {
                            viewModel.selectedDistance = distance
                        } label: {
                            HStack {
                                Text(distance)
                                Spacer()
                                if viewModel.selectedDistance == distance {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(AppTheme.orange)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }

                // Include Online
                Section {
                    Toggle("Include Online Deals", isOn: $viewModel.showOnline)
                        .tint(AppTheme.orange)
                }

                // Categories
                Section("Categories") {
                    Button {
                        viewModel.selectCategory(nil)
                    } label: {
                        HStack {
                            Text("All Categories")
                            Spacer()
                            if viewModel.selectedCategory == nil {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppTheme.orange)
                            }
                        }
                    }
                    .foregroundStyle(.primary)

                    ForEach(viewModel.categories) { category in
                        Button {
                            viewModel.selectCategory(category)
                        } label: {
                            HStack {
                                Text(category.categoryName)
                                Spacer()
                                if viewModel.selectedCategory?.categoryKey == category.categoryKey {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(AppTheme.orange)
                                }
                            }
                        }
                        .foregroundStyle(.primary)

                        // Subcategories
                        if viewModel.selectedCategory?.categoryKey == category.categoryKey,
                           let subs = category.subcategories {
                            ForEach(subs) { sub in
                                Button {
                                    viewModel.toggleSubcategory(sub.categoryKey)
                                } label: {
                                    HStack {
                                        Text(sub.categoryName)
                                            .padding(.leading, 20)
                                        Spacer()
                                        if viewModel.selectedSubcategories.contains(sub.categoryKey) {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(AppTheme.orange)
                                        }
                                    }
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        dismiss()
                        Task { await viewModel.search() }
                    }
                    .foregroundStyle(AppTheme.orange)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
