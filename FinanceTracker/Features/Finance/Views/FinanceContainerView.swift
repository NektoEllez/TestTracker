import SwiftUI

struct FinanceContainerView: View {
    @StateObject private var viewModel = FinanceViewModel()

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                FinanceScreen(viewModel: viewModel)
                fabButton
            }
            .navigationTitle("Finance Tracker")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $viewModel.showingAddTransaction) {
            AddTransactionView { transaction in
                viewModel.addTransaction(transaction)
            }
        }
        .onAppear {
            OrientationManager.shared.lockPortrait()
        }
    }

    private var fabButton: some View {
        Button {
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
    }
}

#Preview("Finance Container") {
    FinanceContainerView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
