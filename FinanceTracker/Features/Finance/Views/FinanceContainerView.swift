import SwiftUI

struct FinanceContainerView: View {
    @StateObject private var viewModel = FinanceViewModel()
    @Environment(\.toastStore) private var toastStore
    
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    currencyMenu
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
        .onAppear {
            OrientationManager.shared.lockPortrait()
        }
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
}

#Preview("Finance Container") {
    FinanceContainerView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
