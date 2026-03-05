import SwiftUI

struct BrowserScreen: View {
    @StateObject private var viewModel: BrowserViewModel
    @Environment(\.toastStore) private var toastStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var isShowingLanguageSheet = false
    @State private var didTriggerFallback = false
    @AppStorage("preferred_color_scheme") private var preferredColorSchemeRaw = "system"
    private let isSettingsOverlayEnabled = false
    
    var onFallbackToFinance: (() -> Void)?

    init(initialURL: URL, onFallbackToFinance: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: BrowserViewModel(initialURL: initialURL))
        self.onFallbackToFinance = onFallbackToFinance
    }
    
    var body: some View {
        ZStack {
            BrowserRepresentable(
                viewModel: viewModel,
                colorScheme: colorScheme,
                onFallbackToFinance: onFallbackToFinance
            )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            if isSettingsOverlayEnabled, #available(iOS 16.0, *) {
                settingsToolbar
            }
            loadingOverlay
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            OrientationManager.shared.unlockAll()
            viewModel.syncWithSystemLanguage()
        }
        .onDisappear {
            OrientationManager.shared.lockPortrait()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSLocale.currentLocaleDidChangeNotification)) { _ in
            viewModel.syncWithSystemLanguage()
        }
        .onChange(of: viewModel.shouldFallbackToFinance) { shouldFallback in
            guard shouldFallback else { return }
            viewModel.shouldFallbackToFinance = false
            fallbackToFinanceIfNeeded()
        }
        .task(id: viewModel.isLoading) {
            guard viewModel.isLoading else { return }
            try? await Task.sleep(nanoseconds: 15_000_000_000)
            if viewModel.isLoading {
                fallbackToFinanceIfNeeded()
            }
        }
        .onChange(of: viewModel.errorMessage) { newValue in
            guard let message = newValue else { return }
            toastStore?.show(
                ToastMessage(
                    text: "Network error: \(message)",
                    icon: "wifi.exclamationmark",
                    style: .warning
                ),
                autoDismissAfter: 3
            )
            viewModel.errorMessage = nil
        }
        .sheet(isPresented: Binding(
            get: { isSettingsOverlayEnabled && isShowingLanguageSheet },
            set: { isShowingLanguageSheet = $0 }
        )) {
            ContentLanguagePickerSheet(
                selectedCode: viewModel.selectedLanguageCode,
                onSelect: { code in
                    Haptics.selection()
                    viewModel.selectLanguage(code)
                    isShowingLanguageSheet = false
                }
            )
            .preferredColorScheme(mappedColorScheme)
        }
        .preferredColorScheme(mappedColorScheme)
    }

    private func fallbackToFinanceIfNeeded() {
        guard !didTriggerFallback else { return }
        didTriggerFallback = true
        viewModel.isLoading = false
        onFallbackToFinance?()
    }
    
    private var settingsToolbar: some View {
        VStack {
            HStack {
                Button {
                    Haptics.impact(.light)
                    isShowingLanguageSheet = true
                } label: {
                    let option = ContentLanguageCatalog.option(for: viewModel.selectedLanguageCode)
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
    
    private var mappedColorScheme: ColorScheme? {
        switch preferredColorSchemeRaw {
            case "light":
                return .light
            case "dark":
                return .dark
            default:
                return nil
        }
    }
}

private struct ContentLanguagePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
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
                    .onChange(of: preferredColorSchemeRaw) { newValue in
                        AppearanceManager.apply(rawValue: newValue)
                    }
                }
                
                Section("Language") {
                    ForEach(ContentLanguageCatalog.supported) { option in
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
            .onAppear {
                AppearanceManager.apply(rawValue: preferredColorSchemeRaw)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                    }
                }
            }
        }
    }
    
    private var effectiveSelectedCode: String {
        pendingSelectionCode ?? selectedCode
    }
}
