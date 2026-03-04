import SwiftUI

struct DotArcLoaderView: View {
    var size: CGFloat = 82
    var dotSize: CGFloat = 16

    @State private var isAnimating = false

    private let colors: [Color] = [
        Color(red: 0.95, green: 0.27, blue: 0.25), // red
        Color(red: 0.21, green: 0.49, blue: 0.88), // blue
        Color(red: 0.24, green: 0.68, blue: 0.31), // green
        Color(red: 0.96, green: 0.82, blue: 0.20), // yellow
        Color(red: 0.98, green: 0.61, blue: 0.12)  // orange
    ]

    private let angles: [Double] = [200, 235, 270, 305, 340]

    var body: some View {
        ZStack {
            ForEach(colors.indices, id: \.self) { index in
                Circle()
                    .fill(colors[index])
                    .frame(width: dotSize, height: dotSize)
                    .offset(position(for: index))
                    .scaleEffect(isAnimating ? 1.0 : 0.7)
                    .opacity(isAnimating ? 1.0 : 0.6)
                    .animation(
                        .easeInOut(duration: 0.55)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1),
                        value: isAnimating
                    )
            }
        }
        .frame(width: size, height: size * 0.7)
        .onAppear {
            isAnimating = true
        }
        .onDisappear {
            isAnimating = false
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading")
    }

    private func position(for index: Int) -> CGSize {
        let radius = size * 0.32
        let angle = angles[index] * .pi / 180
        let x = cos(angle) * radius
        let y = sin(angle) * radius
        return CGSize(width: x, height: y)
    }
}

#Preview("Dot Arc Loader") {
    DotArcLoaderView(size: 100, dotSize: 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
}
