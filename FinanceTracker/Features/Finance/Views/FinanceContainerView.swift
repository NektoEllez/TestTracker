import SwiftUI

struct FinanceContainerView: View {
    @StateObject private var viewModel = FinanceViewModel()
    @Environment(\.toastStore) private var toastStore
    @State private var isShowingSettings = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                FinanceScreen(viewModel: viewModel)
                fabButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackgroundGradient)
            .navigationTitle(Text("finance_tracker"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    analyticsLink
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
                            text: String(localized: "transaction_saved"),
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
            AppSettingsSheet()
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
        .accessibilityLabel("settings")
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
        .accessibilityLabel("add_transaction")
    }
    
    private var currencyMenu: some View {
        Menu {
            Picker("currency", selection: Binding(
                get: { viewModel.selectedCurrencyCode },
                set: { newValue in
                    let previousCode = viewModel.selectedCurrencyCode
                    viewModel.setCurrencyCode(newValue)
                    guard previousCode != viewModel.selectedCurrencyCode else { return }
                    Haptics.selection()
                    toastStore?.show(
                        ToastMessage(
                            text: String(format: String(localized: "currency_set_to"), viewModel.selectedCurrencyCode),
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
            Label("analytics", systemImage: "chart.line.uptrend.xyaxis")
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
        .accessibilityLabel("analytics")
    }
}

#Preview("Finance Container") {
    FinanceContainerView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}

private struct AppSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("preferred_color_scheme") private var preferredColorSchemeRaw = "system"
    @AppStorage("selected_content_language_code") private var selectedLanguageCode = "en"

    var body: some View {
        NavigationView {
            List { settingsContent }
            .listStyle(.insetGrouped)
            .navigationTitle(Text("settings"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                AppearanceManager.apply(rawValue: preferredColorSchemeRaw)
            }
            .toolbar { closeToolbarItem }
        }
    }

    @ViewBuilder
    private var settingsContent: some View {
        appearanceSection
        languageSection
    }

    private var appearanceSection: some View {
        Section(header: Text("appearance")) {
            Picker(selection: $preferredColorSchemeRaw) {
                Text("theme_system").tag("system")
                Text("theme_light").tag("light")
                Text("theme_dark").tag("dark")
            } label: {
                Text("appearance")
            }
            .pickerStyle(.segmented)
            .onChange(of: preferredColorSchemeRaw) { newValue in
                AppearanceManager.apply(rawValue: newValue)
            }
        }
    }

    private var languageSection: some View {
        Section(header: Text("language")) {
            ForEach(ContentLanguageCatalog.supported) { option in
                languageRow(option)
            }
        }
    }

    private func languageRow(_ option: ContentLanguageOption) -> some View {
        let code = ContentLanguageCatalog.normalizedCode(option.code)
        let isSelected = selectedLanguageCode == code
        return Button {
            Haptics.selection()
            selectedLanguageCode = code
        } label: {
            HStack(spacing: 12) {
                Text(option.flag)
                    .font(.title3)
                Text(option.shortLabel)
                    .font(.title3.weight(.medium))
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var closeToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                dismiss()
            } label: {
                Text("close")
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
