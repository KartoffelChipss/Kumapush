import SwiftUI

enum LegalDocuments {
    static let termsURL = URL(string: "https://kumapush.com/terms")!
    static let privacyURL = URL(string: "https://kumapush.com/privacy")!

    static func covers(relayURL: URL) -> Bool {
        relayURL.host() == HTTPRelayClient.defaultRelayURL.host()
    }
}

/// Shown under "Get Started", which registers with the official relay
struct LegalConsentText: View {
    private var message: AttributedString {
        let markdown = "By tapping Get Started, you agree to the [Terms of Service](\(LegalDocuments.termsURL.absoluteString)) and [Privacy Policy](\(LegalDocuments.privacyURL.absoluteString))."
        return (try? AttributedString(markdown: markdown)) ?? AttributedString(markdown)
    }

    var body: some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
}

struct LegalLinksFooter: View {
    var body: some View {
        HStack(spacing: 16) {
            Link("Terms of Service", destination: LegalDocuments.termsURL)
            Link("Privacy Policy", destination: LegalDocuments.privacyURL)
        }
        .font(.footnote)
    }
}
