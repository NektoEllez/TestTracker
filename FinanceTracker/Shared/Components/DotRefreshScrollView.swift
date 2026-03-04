import SwiftUI

struct DotRefreshScrollView<Content: View>: UIViewRepresentable {
    let onRefresh: () async -> Void
    let content: Content

    init(
        onRefresh: @escaping () async -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.onRefresh = onRefresh
        self.content = content()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, content: content)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .automatic

        let hostedView = context.coordinator.hostingController.view!
        hostedView.backgroundColor = .clear
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hostedView)

        hostedView.setContentCompressionResistancePriority(.required, for: .vertical)

        NSLayoutConstraint.activate([
            hostedView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            hostedView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostedView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            hostedView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        scrollView.refreshControl = context.coordinator.refreshControl
        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.hostingController.rootView = content
        context.coordinator.hostingController.view.invalidateIntrinsicContentSize()
    }

    final class Coordinator: NSObject {
        var parent: DotRefreshScrollView
        let hostingController: UIHostingController<Content>
        let refreshControl = UIRefreshControl()

        private let loaderHost: UIHostingController<DotArcLoaderView>
        private var refreshTask: Task<Void, Never>?

        init(parent: DotRefreshScrollView, content: Content) {
            self.parent = parent
            self.hostingController = UIHostingController(rootView: content)
            self.loaderHost = UIHostingController(
                rootView: DotArcLoaderView(size: 54, dotSize: 10)
            )
            super.init()
            configureRefreshControl()
        }

        deinit {
            refreshTask?.cancel()
        }

        private func configureRefreshControl() {
            refreshControl.tintColor = .clear
            refreshControl.backgroundColor = .clear
            refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)

            let loaderView = loaderHost.view!
            loaderView.translatesAutoresizingMaskIntoConstraints = false
            loaderView.backgroundColor = .clear
            loaderView.isHidden = true

            refreshControl.addSubview(loaderView)
            NSLayoutConstraint.activate([
                loaderView.centerXAnchor.constraint(equalTo: refreshControl.centerXAnchor),
                loaderView.centerYAnchor.constraint(equalTo: refreshControl.centerYAnchor),
                loaderView.widthAnchor.constraint(equalToConstant: 58),
                loaderView.heightAnchor.constraint(equalToConstant: 44)
            ])
        }

        @objc
        private func handleRefresh() {
            guard refreshTask == nil else { return }

            Haptics.impact(.light)
            loaderHost.view.isHidden = false
            refreshTask = Task { [weak self] in
                guard let self else { return }
                await self.parent.onRefresh()
                await MainActor.run {
                    self.loaderHost.view.isHidden = true
                    self.refreshControl.endRefreshing()
                    self.refreshTask = nil
                }
            }
        }
    }
}
