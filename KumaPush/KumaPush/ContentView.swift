import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .needsRegistration:
                GetStartedView(
                    relayOption: $viewModel.relayOption,
                    customAddress: $viewModel.customRelayAddress,
                    isRegistering: viewModel.isRegistering,
                    errorMessage: viewModel.errorMessage,
                    onGetStarted: { Task { await viewModel.getStartedTapped() } }
                )
            case .registered(let device):
                RegisteredView(
                    device: device,
                    isUnregistering: viewModel.isUnregistering,
                    errorMessage: viewModel.errorMessage,
                    onUnregister: { Task { await viewModel.unregisterTapped() } }
                )
            }
        }
        .padding()
        .task {
            await viewModel.start()
        }
    }
}

private struct GetStartedView: View {
    @Binding var relayOption: RelayOption
    @Binding var customAddress: String
    let isRegistering: Bool
    let errorMessage: String?
    let onGetStarted: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Picker("Relay", selection: $relayOption) {
                Text("kumapush.com").tag(RelayOption.defaultRelay)
                Text("Custom").tag(RelayOption.custom)
            }
            .pickerStyle(.segmented)

            if relayOption == .custom {
                TextField("http://localhost:3000", text: $customAddress)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            Button("Get Started", action: onGetStarted)
                .disabled(isRegistering)

            if isRegistering {
                ProgressView()
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }
}

private struct RegisteredView: View {
    let device: Device
    let isUnregistering: Bool
    let errorMessage: String?
    let onUnregister: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text("You're all set!")
                .font(.headline)
            Text("Your ID")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(device.id)
                .font(.system(.body, design: .monospaced))

            Button("Unregister Device", role: .destructive, action: onUnregister)
                .disabled(isUnregistering)
                .padding(.top, 24)

            if isUnregistering {
                ProgressView()
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
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

private final class PreviewRelayClient: RelayClient {
    var baseURL = HTTPRelayClient.defaultRelayURL
    func registerDevice(token: String) async throws -> Device {
        Device(id: "preview-id", deviceToken: token, lastSuccessfulNotification: "", dateAdded: "")
    }
    func getDevice(byToken token: String) async throws -> Device {
        throw RelayError.notFound
    }
    func getDevice(byId id: String) async throws -> Device {
        throw RelayError.notFound
    }
    func unregisterDevice(token: String) async throws {}
}

private final class PreviewPushRegistrar: PushRegistrar {
    func requestAuthorizationAndRegister() async throws -> String { "preview-token" }
}

private final class PreviewDeviceStore: DeviceStore {
    var deviceId: String?
    var relayBaseURL: URL?
}
