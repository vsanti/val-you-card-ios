import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var selectedTab: Tab = .home

    enum Tab: Hashable {
        case home, search, account
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)

            SearchTab()
                .tabItem {
                    Label("Deals", systemImage: "magnifyingglass")
                }
                .tag(Tab.search)

            AccountTab()
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
                .tag(Tab.account)
        }
        .tint(AppTheme.orange)
        .task {
            await auth.restoreSession()
        }
    }
}

private struct HomeTab: View {
    @EnvironmentObject var container: DependencyContainer

    var body: some View {
        NavigationStack {
            HomeView(viewModel: container.makeHomeViewModel())
        }
    }
}

private struct SearchTab: View {
    @EnvironmentObject var container: DependencyContainer

    var body: some View {
        NavigationStack {
            SearchView(viewModel: container.makeSearchViewModel())
        }
    }
}

private struct AccountTab: View {
    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        NavigationStack {
            if auth.isAuthenticated {
                AccountView(viewModel: container.makeAccountViewModel())
            } else {
                SignInView()
            }
        }
    }
}
