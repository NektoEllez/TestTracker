import SwiftUI

struct LoadingIndicatorView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 16) {
            LottieLoaderView()
                .frame(width: 80, height: 80)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
