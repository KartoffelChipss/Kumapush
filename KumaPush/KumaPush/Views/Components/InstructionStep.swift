import SwiftUI

struct InstructionStep<Content: View>: View {
    let number: Int
    @ViewBuilder var content: Content

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(.tint))
            content
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
