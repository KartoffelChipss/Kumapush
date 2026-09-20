import SwiftUI

struct RegisteredView: View {
    let device: Device
    let relayBaseURL: URL
    let isUnregistering: Bool
    let errorMessage: String?
    let onDownLevelChange: (NotificationLevel) -> Void
    let onUnregister: () -> Void

    @State private var showingUnregisterConfirmation = false

    private var webhookURLString: String {
        relayBaseURL.appendingPathComponent("wh/\(device.id)").absoluteString
    }

    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.accent)
                Text("You're all set!")
                    .font(.title2.bold())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("YOUR DEVICE ID")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                CopyableValue(value: device.id)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 16) {
                Text("Connect Uptime Kuma")
                    .font(.headline)

                InstructionStep(number: 1) {
                    Text("In Uptime Kuma, add a new notification of type **Webhook**.")
                }
                InstructionStep(number: 2) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Set the **Post URL** to:")
                        CopyableValue(value: webhookURLString)
                    }
                }
                InstructionStep(number: 3) {
                    Text("Set **Request Body** to **Preset – application/json**.")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 12) {
                Text("Down notifications")
                    .font(.headline)

                Picker("Down notifications", selection: Binding(
                    get: { device.downNotificationLevel },
                    set: onDownLevelChange
                )) {
                    ForEach(NotificationLevel.allCases) { level in
                        Text(level.title).tag(level)
                    }
                }
                .pickerStyle(.segmented)

                Text(device.downNotificationLevel.detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 16))

            VStack(spacing: 12) {
                Button(role: .destructive) {
                    showingUnregisterConfirmation = true
                } label: {
                    Text("Unregister Device")
                        .opacity(isUnregistering ? 0 : 1)
                        .overlay {
                            if isUnregistering {
                                ProgressView()
                                    .controlSize(.small)
                            }
                        }
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(isUnregistering)
                .confirmationDialog(
                    "Unregister this device?",
                    isPresented: $showingUnregisterConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Unregister Device", role: .destructive, action: onUnregister)
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("You'll stop receiving push notifications until you register again.")
                }

                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }

            if LegalDocuments.covers(relayURL: relayBaseURL) {
                LegalLinksFooter()
            }
        }
    }
}
