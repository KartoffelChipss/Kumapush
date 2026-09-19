import SwiftUI

struct GetStartedView: View {
    @Binding var relayOption: RelayOption
    @Binding var customAddress: String
    let isRegistering: Bool
    let errorMessage: String?
    @Binding var insecureRelayURL: URL?
    let onGetStarted: () -> Void
    let onContinueInsecure: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 12) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.tint)
                Text("Welcome to KumaPush")
                    .font(.title2.bold())
                Text("Get push notifications from Uptime Kuma sent straight to this device.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("RELAY SERVER")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Picker("Relay", selection: $relayOption) {
                    Text("kumapush.com").tag(RelayOption.defaultRelay)
                    Text("Custom").tag(RelayOption.custom)
                }
                .pickerStyle(.segmented)

                if relayOption == .custom {
                    TextField("http://localhost:3000", text: $customAddress)
                        .padding(12)
                        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 10))
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .padding(16)
            .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 16))

            VStack(spacing: 12) {
                Button(action: onGetStarted) {
                    Group {
                        if isRegistering {
                            ProgressView()
                        } else {
                            Text("Get Started")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isRegistering)

                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
        }
        .alert(
            "Use an insecure connection?",
            isPresented: Binding(get: { insecureRelayURL != nil }, set: { if !$0 { insecureRelayURL = nil } })
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Continue", role: .destructive, action: onContinueInsecure)
        } message: {
            Text("\(insecureRelayURL?.absoluteString ?? "This relay") doesn't use HTTPS. Anything sent to it, including your device token, can be read by others on the network.")
        }
    }
}
