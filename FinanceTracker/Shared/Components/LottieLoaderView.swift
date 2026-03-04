import SwiftUI
import Lottie

struct LottieLoaderView: UIViewRepresentable {
    let animationName: String
    let loopMode: LottieLoopMode

    init(animationName: String = "Boat_Loader", loopMode: LottieLoopMode = .loop) {
        self.animationName = animationName
        self.loopMode = loopMode
    }

    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.play()
        return animationView
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        if !uiView.isAnimationPlaying {
            uiView.play()
        }
    }
}
