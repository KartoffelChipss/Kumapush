import SwiftUI
import UIKit

struct CopyableValue: View {
    let value: String
    @State private var copied = false

    var body: some View {
        HStack {
            Text(value)
                .font(.system(.footnote, design: .monospaced))
                .textSelection(.enabled)
                .lineLimit(2)
                .truncationMode(.middle)

            Spacer(minLength: 8)

            Button {
                UIPasteboard.general.string = value
                copied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
            } label: {
                Image(systemName: copied ? "checkmark" : "doc.on.doc")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(10)
        .background(Color.appBackground, in: RoundedRectangle(cornerRadius: 8))
    }
}
