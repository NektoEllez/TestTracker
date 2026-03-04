import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var opacity: Double = 0
    private let logoSize: CGFloat = 200
    
    var body: some View {
        ZStack {
            Color.appAccent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                iconView
                titleView
                primaryLoader
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
        Image("Logo")
            .resizable()
            .scaledToFit()
            .frame(width: logoSize, height: logoSize)
            .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
            .scaleEffect(isAnimating ? 1.04 : 0.96)
            .opacity(opacity)
    }
    
    private var titleView: some View {
        Text("app_title")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .opacity(opacity)
    }
    
    private var primaryLoader: some View {
        DotArcLoaderView(size: 84, dotSize: 15)
            .padding(10)
            .background(Color.white.opacity(0.16))
            .appGlassSurface(cornerRadius: 20)
            .opacity(opacity)
    }
}

#Preview("Splash") {
    SplashView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
