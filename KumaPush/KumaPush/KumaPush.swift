import SwiftUI

@main struct KumaPush: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = AppViewModel(
        relay: HTTPRelayClient(),
        pushRegistrar: APNsPushRegistrar.shared,
        store: UserDefaultsDeviceStore()
    )

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
