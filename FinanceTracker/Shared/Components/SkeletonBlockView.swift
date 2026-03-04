import SwiftUI

struct SkeletonBlockView: View {
    var width: CGFloat? = nil
    var height: CGFloat
    var cornerRadius: CGFloat = 10

    @State private var shimmerOffset: CGFloat = -1.2

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.primary.opacity(0.08))
            .overlay {
                GeometryReader { proxy in
                    let travel = proxy.size.width + proxy.size.height

                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.55),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: proxy.size.width * 0.7, height: proxy.size.height * 2)
                    .rotationEffect(.degrees(20))
                    .offset(x: shimmerOffset * travel)
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
            .frame(width: width, height: height)
            .onAppear {
                shimmerOffset = -1.2
                withAnimation(.linear(duration: 1.05).repeatForever(autoreverses: false)) {
                    shimmerOffset = 1.2
                }
            }
            .accessibilityHidden(true)
    }
}

#Preview("Skeleton Block") {
    VStack(spacing: 12) {
        SkeletonBlockView(width: 120, height: 16, cornerRadius: 8)
        SkeletonBlockView(height: 44, cornerRadius: 12)
    }
    .padding(20)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)
}
