import SwiftUI

struct FinanceContainerView: View {
    @StateObject private var viewModel = FinanceViewModel()
    @Environment(\.toastStore) private var toastStore
    @State private var isShowingSettings = false
    var onOpenBrowser: (() -> Void)?

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                FinanceScreen(viewModel: viewModel)
                fabButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackgroundGradient)
            .navigationTitle("Finance Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 12) {
                        if AppStorageManager.shared.browserConfigURL != nil {
                            Button {
                                Haptics.impact(.light)
                                onOpenBrowser?()
                            } label: {
                                Label("Web", systemImage: "globe")
                                    .labelStyle(.iconOnly)
                                    .font(.subheadline.weight(.semibold))
                            }
                            .accessibilityLabel("Open web version")
                        }
                        analyticsLink
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        settingsButton
                        currencyMenu
                    }
                }
            }
            .background(TransparentNavigationBarConfigurator())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $viewModel.showingAddTransaction) {
            AddTransactionView { transaction in
                do {
                    try viewModel.addTransaction(transaction)
                    toastStore?.show(
                        ToastMessage(
                            text: "Transaction saved",
                            icon: "checkmark.circle.fill",
                            style: .success
                        ),
                        autoDismissAfter: 2
                    )
                } catch {
                    toastStore?.show(
                        ToastMessage(
                            text: error.localizedDescription,
                            icon: "xmark.octagon.fill",
                            style: .error
                        )
                    )
                    throw error
                }
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            AppSettingsSheet(onOpenBrowser: onOpenBrowser)
        }
        .onAppear {
            OrientationManager.shared.lockPortrait()
        }
    }
    
    private var settingsButton: some View {
        Button {
            Haptics.impact(.light)
            isShowingSettings = true
        } label: {
            Image(systemName: "gearshape")
                .font(.subheadline.weight(.semibold))
        }
        .accessibilityLabel("Settings")
    }
    
    private var fabButton: some View {
        Button {
            Haptics.impact(.medium)
            viewModel.showingAddTransaction = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.appAccent.opacity(0.8))
                .clipShape(Circle())
                .appGlassSurface(cornerRadius: 28, style: .interactive)
                .shadow(color: Color.appAccent.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
        .accessibilityLabel("Add transaction")
    }
    
    private var currencyMenu: some View {
        Menu {
            Picker("Currency", selection: Binding(
                get: { viewModel.selectedCurrencyCode },
                set: { newValue in
                    let previousCode = viewModel.selectedCurrencyCode
                    viewModel.setCurrencyCode(newValue)
                    guard previousCode != viewModel.selectedCurrencyCode else { return }
                    Haptics.selection()
                    toastStore?.show(
                        ToastMessage(
                            text: "Currency set to \(viewModel.selectedCurrencyCode)",
                            icon: "dollarsign.circle.fill",
                            style: .default
                        ),
                        autoDismissAfter: 1.8
                    )
                }
            )) {
                ForEach(CurrencyCatalog.popular) { option in
                    Text(option.title).tag(option.code)
                }
            }
        } label: {
            Label(viewModel.selectedCurrencyCode, systemImage: "dollarsign.circle")
                .labelStyle(.titleAndIcon)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Color.cardBackground.opacity(0.28),
                    in: Capsule()
                )
                .appGlassSurface(cornerRadius: 999, style: .interactive)
        }
    }

    private var analyticsLink: some View {
        NavigationLink(destination: FinanceAnalyticsScreen(viewModel: viewModel)) {
            Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                .labelStyle(.titleAndIcon)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Color.cardBackground.opacity(0.28),
                    in: Capsule()
                )
                .appGlassSurface(cornerRadius: 999, style: .interactive)
        }
        .accessibilityLabel("Open analytics")
    }
}

#Preview("Finance Container") {
    FinanceContainerView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}

private struct AppSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("preferred_color_scheme") private var preferredColorSchemeRaw = "system"
    @State private var selectedLanguageCode: String = AppStorageManager.shared.effectiveContentLanguageCode
    var onOpenBrowser: (() -> Void)?

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
                if AppStorageManager.shared.browserConfigURL != nil, let openBrowser = onOpenBrowser {
                    Section {
                        Button {
                            dismiss()
                            openBrowser()
                        } label: {
                            Label("Open web version", systemImage: "globe")
                        }
                    }
                }
                Section("Language") {
                    ForEach(ContentLanguageCatalog.supported) { option in
                        Button {
                            Haptics.selection()
                            let code = ContentLanguageCatalog.normalizedCode(option.code)
                            selectedLanguageCode = code
                            AppStorageManager.shared.selectedContentLanguageCode = code
                        } label: {
                            HStack(spacing: 12) {
                                Text(option.flag).font(.title3)
                                Text(option.shortLabel).font(.title3.weight(.medium))
                                Spacer()
                                if selectedLanguageCode == option.code {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                AppearanceManager.apply(rawValue: preferredColorSchemeRaw)
                selectedLanguageCode = AppStorageManager.shared.effectiveContentLanguageCode
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

private struct TransparentNavigationBarConfigurator: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        let navController = uiViewController.navigationController
        ?? findNavigationController(from: uiViewController.view)
        
        guard let navigationController = navController else { return }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.isTranslucent = true
    }
    
    private func findNavigationController(from view: UIView?) -> UINavigationController? {
        var responder: UIResponder? = view
        while let next = responder {
            if let nav = next as? UINavigationController { return nav }
            if let vc = next as? UIViewController, let nav = vc.navigationController { return nav }
            responder = next.next
        }
        return nil
    }
}
