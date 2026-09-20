import SwiftUI

struct GetStartedView: View {
    @Binding var relayOption: RelayOption
    @Binding var customAddress: String
    let isRegistering: Bool
    let errorMessage: String?
    @Binding var insecureRelayURL: URL?
    let onGetStarted: () -> Void
    let onContinueInsecure: () -> Void

    @State private var showingCustomRelay = false
    @State private var customRelayAttempted = false

    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 12) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
                Text("Welcome to KumaPush")
                    .font(.title2.bold())
                Text("Get push notifications from Uptime Kuma sent straight to this device.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                Button {
                    relayOption = .defaultRelay
                    onGetStarted()
                } label: {
                    Text("Get Started")
                        .opacity(isRegistering ? 0 : 1)
                        .overlay {
                            if isRegistering {
                                ProgressView()
                                    .controlSize(.small)
                            }
                        }
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isRegistering)

                LegalConsentText()

                Button("Use custom relay") {
                    customRelayAttempted = false
                    showingCustomRelay = true
                }
                .font(.footnote)
                .disabled(isRegistering)

                if let errorMessage, !showingCustomRelay {
                    ErrorLabel(message: errorMessage)
                }
            }
        }
        .padding(.top, 20)
        .sheet(isPresented: $showingCustomRelay) {
            CustomRelaySheet(
                address: $customAddress,
                isRegistering: isRegistering,
                errorMessage: customRelayAttempted ? errorMessage : nil,
                insecureRelayURL: $insecureRelayURL,
                onConnect: {
                    customRelayAttempted = true
                    relayOption = .custom
                    onGetStarted()
                },
                onContinueInsecure: onContinueInsecure
            )
        }
    }
}

private struct CustomRelaySheet: View {
    @Binding var address: String
    let isRegistering: Bool
    let errorMessage: String?
    @Binding var insecureRelayURL: URL?
    let onConnect: () -> Void
    let onContinueInsecure: () -> Void

    @FocusState private var addressFocused: Bool
    @State private var showingInsecureAlert = false

    private var canConnect: Bool {
        !isRegistering && !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Custom Relay")
                    .font(.title3.bold())
                Text("Enter the address of the relay server you host yourself.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            TextField("https://relay.example.com", text: $address)
                .padding(12)
                .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 10))
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.go)
                .focused($addressFocused)
                .onSubmit { if canConnect { onConnect() } }

            Button(action: onConnect) {
                Text("Continue")
                    .opacity(isRegistering ? 0 : 1)
                    .overlay {
                        if isRegistering {
                            ProgressView()
                                .controlSize(.small)
                        }
                    }
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!canConnect)

            if let errorMessage {
                ErrorLabel(message: errorMessage)
            }

            Spacer(minLength: 0)
        }
        .padding(24)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onAppear { addressFocused = true }
        .onChange(of: insecureRelayURL) { _, url in
            showingInsecureAlert = url != nil
        }
        .alert("Use an insecure connection?", isPresented: $showingInsecureAlert) {
            Button("Cancel", role: .cancel) { insecureRelayURL = nil }
            Button("Continue", role: .destructive) {
                insecureRelayURL = nil
                onContinueInsecure()
            }
        } message: {
            Text("\(insecureRelayURL?.absoluteString ?? "This relay") doesn't use HTTPS. Anything sent to it, including your device token, can be read by others on the network.")
        }
    }
}

private struct ErrorLabel: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle.fill")
            .font(.footnote)
            .foregroundStyle(.red)
    }
}
