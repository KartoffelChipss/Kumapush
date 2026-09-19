import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        ScrollView {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView()
                        .padding(.top, 120)
                case .needsRegistration:
                    GetStartedView(
                        relayOption: $viewModel.relayOption,
                        customAddress: $viewModel.customRelayAddress,
                        isRegistering: viewModel.isRegistering,
                        errorMessage: viewModel.errorMessage,
                        insecureRelayURL: $viewModel.pendingInsecureRelayURL,
                        onGetStarted: { Task { await viewModel.getStartedTapped() } },
                        onContinueInsecure: { Task { await viewModel.getStartedTapped(allowInsecure: true) } }
                    )
                case .registered(let device):
                    RegisteredView(
                        device: device,
                        relayBaseURL: viewModel.currentRelayURL,
                        isUnregistering: viewModel.isUnregistering,
                        errorMessage: viewModel.errorMessage,
                        onDownLevelChange: { level in Task { await viewModel.downNotificationLevelChanged(to: level) } },
                        onUnregister: { Task { await viewModel.unregisterTapped() } }
                    )
                }
            }
            .frame(maxWidth: 480)
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .task {
            await viewModel.start()
        }
    }
}

#Preview("Needs registration") {
    ContentView(viewModel: AppViewModel(
        relay: PreviewRelayClient(),
        pushRegistrar: PreviewPushRegistrar(),
        store: PreviewDeviceStore()
    ))
}

#Preview("Registered") {
    let viewModel = AppViewModel(
        relay: PreviewRelayClient(),
        pushRegistrar: PreviewPushRegistrar(),
        store: PreviewDeviceStore()
    )
    ContentView(viewModel: viewModel)
        .task {
            await viewModel.getStartedTapped()
        }
}
