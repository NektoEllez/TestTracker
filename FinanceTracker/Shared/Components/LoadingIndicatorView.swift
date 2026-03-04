import SwiftUI

struct LoadingIndicatorView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 12) {
            DotArcLoaderView(size: 86, dotSize: 16)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
