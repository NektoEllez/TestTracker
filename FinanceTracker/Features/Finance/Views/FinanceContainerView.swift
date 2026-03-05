import SwiftUI

struct FinanceContainerView: View {
    @StateObject private var viewModel: FinanceViewModel
    @Environment(\.toastStore) private var toastStore
    @State private var isShowingSettings = false
    @State private var contentOffsetY: CGFloat = 0
    private let storageManager: AppStorageManager

    @MainActor
    init(
        storageManager: AppStorageManager? = nil,
        transactionStore: TransactionStoreProtocol? = nil
    ) {
        let resolvedStorageManager = storageManager ?? .shared
        let resolvedTransactionStore = transactionStore ?? TransactionStore()
        self.storageManager = resolvedStorageManager
        _viewModel = StateObject(
            wrappedValue: FinanceViewModel(
                store: resolvedTransactionStore,
                storageManager: resolvedStorageManager
            )
        )
    }

    var body: some View {
        navigationContainer
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $viewModel.showingAddTransaction) {
            addTransactionSheet
        }
        .sheet(isPresented: $isShowingSettings) {
            AppSettingsSheet()
        }
        .onAppear {
            lockPortrait()
        }
    }

    private var navigationContainer: some View {
        NavigationView {
            navigationContent
        }
    }

    private var navigationContent: some View {
        contentWithFab
            .navigationTitle(Text("finance_tracker"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                navigationToolbar
            }
            .appNavigationBarStyle(background: .clear)
    }

    @ViewBuilder
    private var contentWithFab: some View {
        if #available(iOS 26.0, *) {
            FinanceContainerPlatformContentView(
                viewModel: viewModel,
                isFabVisible: contentOffsetY > -300,
                onScrollOffsetChange: { offset in
                    contentOffsetY = offset
                },
                onAddTransaction: showAddTransaction
            )
        } else {
            FinanceContainerPlatformContentView(
                viewModel: viewModel,
                isFabVisible: true,
                onScrollOffsetChange: nil,
                onAddTransaction: showAddTransaction
            )
        }
    }

    @ToolbarContentBuilder
    private var navigationToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            analyticsLink 
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            trailingToolbarContent
        }
    }

    private var trailingToolbarContent: some View {
        HStack(spacing: 12) {
            settingsButton
            currencyMenu
        }
    }

    private var addTransactionSheet: some View {
        AddTransactionView(storageManager: storageManager) { transaction in
            try handleAddTransaction(transaction)
        }
    }

    private func lockPortrait() {
        OrientationManager.shared.lockPortrait()
    }

    private func handleAddTransaction(_ transaction: Transaction) throws {
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

    private var settingsButton: some View {
        Button {
            showSettings()
        } label: {
            Image(systemName: "gearshape")
                .font(.subheadline.weight(.semibold))
        }
        .accessibilityLabel("settings")
    }
    
    private var currencyMenu: some View {
        Menu {
            ForEach(CurrencyCatalog.popular) { option in
                let isSelected = option.code == viewModel.selectedCurrencyCode
                Button {
                    updateCurrency(option.code)
                } label: {
                    if isSelected {
                        Label(option.title, systemImage: "checkmark")
                    } else {
                        Text(option.title)
                    }
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

    private func showSettings() {
        Haptics.impact(.light)
        isShowingSettings = true
    }

    private func showAddTransaction() {
        Haptics.impact(.medium)
        viewModel.showingAddTransaction = true
    }

    private func updateCurrency(_ newValue: String) {
        Haptics.selection()
        let previousCode = viewModel.selectedCurrencyCode
        viewModel.setCurrencyCode(newValue)
        guard previousCode != viewModel.selectedCurrencyCode else { return }
        toastStore?.show(
            ToastMessage(
                text: String(format: String(localized: "currency_set_to"), viewModel.selectedCurrencyCode),
                icon: "dollarsign.circle.fill",
                style: .default
            ),
            autoDismissAfter: 1.8
        )
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
        .simultaneousGesture(
            TapGesture().onEnded {
                Haptics.selection()
            }
        )
        .accessibilityLabel("analytics")
    }
}

#Preview("Finance Container") {
    FinanceContainerView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}

private struct FinanceContainerPlatformContentView: View {
    let viewModel: FinanceViewModel
    let isFabVisible: Bool
    let onScrollOffsetChange: ((CGFloat) -> Void)?
    let onAddTransaction: () -> Void

    var body: some View {
        FinanceScreen(
            viewModel: viewModel,
            onScrollOffsetChange: onScrollOffsetChange
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackgroundGradient.ignoresSafeArea())
        .overlay(alignment: .bottomTrailing) {
            FinanceFloatingActionButton(
                isVisible: isFabVisible,
                action: onAddTransaction
            )
        }
    }
}

private struct FinanceFloatingActionButton: View {
    let isVisible: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
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
        .accessibilityLabel("add_transaction")
        .padding(.trailing, 20)
        .padding(.bottom, 20)
        .opacity(isVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: isVisible)
    }
}

private struct AppSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var themeSettings = ThemeSettings.shared
    @AppStorage("selected_content_language_code") private var selectedLanguageCode = "en"

    var body: some View {
        NavigationView {
            List { settingsContent }
            .listStyle(.insetGrouped)
            .navigationTitle(Text("settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { closeToolbarItem }
            .appNavigationBarStyle()
        }
        .preferredColorScheme(themeSettings.colorScheme)
    }

    @ViewBuilder
    private var settingsContent: some View {
        appearanceSection
        languageSection
    }

    private var appearanceSection: some View {
        Section(header: Text("appearance")) {
            Picker(selection: themeSettings.modeBinding) {
                Text("theme_system").tag(ThemeMode.system)
                Text("theme_light").tag(ThemeMode.light)
                Text("theme_dark").tag(ThemeMode.dark)
            } label: {
                Text("appearance")
            }
            .pickerStyle(.segmented)
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
                Haptics.selection()
                dismiss()
            } label: {
                Text("close")
            }
        }
    }
}
