import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.appAccent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                iconView
                titleView
                lottieLoader
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) {
                opacity = 1
            }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }

    private var iconView: some View {
        Image(systemName: "dollarsign.circle.fill")
            .font(.system(size: 80))
            .foregroundColor(.white)
            .scaleEffect(isAnimating ? 1.1 : 0.95)
            .opacity(opacity)
    }

    private var titleView: some View {
        Text("FinanceTracker")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .opacity(opacity)
    }

    private var lottieLoader: some View {
        LottieLoaderView(animationName: "Boat_Loader")
            .frame(width: 90, height: 90)
            .padding(12)
            .background(Color.white.opacity(0.16))
            .appGlassSurface(cornerRadius: 20)
            .opacity(opacity)
            .padding(.top, 8)
    }
}

#Preview("Splash") {
    SplashView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
