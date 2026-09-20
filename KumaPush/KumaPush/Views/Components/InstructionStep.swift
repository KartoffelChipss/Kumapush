import SwiftUI

struct InstructionStep<Content: View>: View {
    let number: Int
    @ViewBuilder var content: Content

    @ScaledMetric(relativeTo: .caption) private var badgeSize: CGFloat = 22

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: badgeSize, height: badgeSize)
                .background(Circle().fill(.tint))
            content
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
