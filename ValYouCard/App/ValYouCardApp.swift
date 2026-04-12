import SwiftUI

@main
struct ValYouCardApp: App {
    @StateObject private var container = DependencyContainer()
    @StateObject private var authViewModel: AuthViewModel

    init() {
        let container = DependencyContainer()
        _container = StateObject(wrappedValue: container)
        _authViewModel = StateObject(wrappedValue: container.makeAuthViewModel())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .environmentObject(authViewModel)
        }
    }
}
