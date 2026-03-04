import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    
    @State private var currentPage = 0
    
    private let pages = OnboardingPage.pages
    
    var body: some View {
        VStack {
            tabContent
            bottomControls
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackgroundGradient.ignoresSafeArea())
    }
    
    private var tabContent: some View {
        TabView(selection: $currentPage) {
            ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                OnboardingPageView(page: page)
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
    
    private var bottomControls: some View {
        HStack {
            skipButton
            Spacer()
            nextButton
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
    
    private var skipButton: some View {
        Button("Skip") {
            onComplete()
        }
        .font(.body)
        .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    private var nextButton: some View {
        if currentPage < pages.count - 1 {
            Button("Next") {
                withAnimation {
                    currentPage += 1
                }
            }
            .font(.body.weight(.semibold))
            .foregroundColor(.appAccent)
        } else {
            Button("Get Started") {
                onComplete()
            }
            .font(.body.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.appAccent.opacity(0.85))
            .clipShape(Capsule())
            .appGlassSurface(cornerRadius: 999, style: .interactive)
        }
    }
}

#Preview("Onboarding") {
    OnboardingView(onComplete: {})
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
