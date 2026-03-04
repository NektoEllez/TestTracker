import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            iconView
            titleView
            descriptionView
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    private var iconView: some View {
        Image(systemName: page.imageName)
            .font(.system(size: 80))
            .foregroundColor(.appAccent)
            .padding(.bottom, 8)
    }
    
    private var titleView: some View {
        Text(page.title)
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
    }
    
    private var descriptionView: some View {
        Text(page.description)
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
    }
}
