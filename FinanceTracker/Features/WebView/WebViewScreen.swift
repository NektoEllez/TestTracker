import SwiftUI

struct WebViewScreen: View {
    @StateObject private var viewModel: WebViewModel
    @Environment(\.toastStore) private var toastStore
    @State private var isShowingLanguageSheet = false

    init(initialURL: URL) {
        _viewModel = StateObject(wrappedValue: WebViewModel(initialURL: initialURL))
    }

    var body: some View {
        ZStack {
            WebViewRepresentable(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            if #available(iOS 16.0, *) {
                settingsToolbar
            }
            loadingOverlay
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            OrientationManager.shared.unlockAll()
        }
        .onDisappear {
            OrientationManager.shared.lockPortrait()
        }
        .onChange(of: viewModel.errorMessage) { newValue in
            guard let message = newValue else { return }
            toastStore?.show(
                ToastMessage(
                    text: "Web error: \(message)",
                    icon: "wifi.exclamationmark",
                    style: .warning
                ),
                autoDismissAfter: 3
            )
            viewModel.errorMessage = nil
        }
        .sheet(item: $viewModel.safariDestination, onDismiss: {
            viewModel.safariDestination = nil
        }) { destination in
            SafariWebViewRepresentable(url: destination.url)
        }
        .sheet(isPresented: $isShowingLanguageSheet) {
            WebLanguagePickerSheet(
                selectedCode: viewModel.selectedLanguageCode,
                onSelect: { code in
                    Haptics.selection()
                    viewModel.selectLanguage(code)
                    isShowingLanguageSheet = false
                }
            )
        }
    }

    private var settingsToolbar: some View {
        VStack {
            HStack {
                Button {
                    Haptics.impact(.light)
                    isShowingLanguageSheet = true
                } label: {
                    let option = WebLanguageCatalog.option(for: viewModel.selectedLanguageCode)
                    HStack(spacing: 8) {
                        Image(systemName: "gearshape")
                            .font(.subheadline.weight(.semibold))
                        Text(option.flag)
                        Text(option.shortLabel.uppercased())
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.34), in: Capsule())
                    .appGlassSurface(cornerRadius: 999, style: .interactive)
                }
                .padding(.leading, 12)
                .padding(.top, 8)

                Spacer()
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isLoading {
            ZStack {
                Color.black.opacity(0.08)

                VStack(spacing: 10) {
                    DotArcLoaderView(size: 70, dotSize: 14)
                    Text("Loading...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    Color.cardBackground.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                .appGlassSurface(cornerRadius: 14)
            }
            .transition(.opacity)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

private struct WebLanguagePickerSheet: View {
    let selectedCode: String
    let onSelect: (String) -> Void
    @AppStorage("preferred_color_scheme") private var preferredColorSchemeRaw = "system"
    @State private var pendingSelectionCode: String?

    var body: some View {
        NavigationView {
            List {
                Section("Appearance") {
                    Picker("Theme", selection: $preferredColorSchemeRaw) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                }

                Section("Language") {
                    ForEach(WebLanguageCatalog.supported) { option in
                        Button {
                            let tappedCode = option.code
                            pendingSelectionCode = tappedCode
                            Haptics.selection()
                            Task { @MainActor in
                                try? await Task.sleep(nanoseconds: 80_000_000)
                                onSelect(tappedCode)
                            }
                        } label: {
                            let isSelected = effectiveSelectedCode == option.code
                            HStack(spacing: 12) {
                                Text(option.flag)
                                    .font(.title3)
                                Text(option.shortLabel)
                                    .font(.title3.weight(.medium))
                                    .foregroundColor(.primary)
                                Spacer()
                                if isSelected {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 11, height: 11)
                                }
                            }
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(
                            (effectiveSelectedCode == option.code)
                                ? Color.primary.opacity(0.14)
                                : Color.clear
                        )
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var effectiveSelectedCode: String {
        pendingSelectionCode ?? selectedCode
    }
}
