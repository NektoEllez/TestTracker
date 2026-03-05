import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    private let logoSize: CGFloat = 130
    
    var body: some View {
        ZStack {
            Color("LaunchBackground")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            iconView
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.95).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    private var iconView: some View {
        Image("Logo")
            .resizable()
            .scaledToFit()
            .frame(width: logoSize, height: logoSize)
            .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
            .scaleEffect(isAnimating ? 1.03 : 1.0)
    }
}

#Preview("Splash") {
    SplashView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
