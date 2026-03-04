import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddTransactionViewModel()

    let onSave: (Transaction) -> Void

    var body: some View {
        NavigationView {
            Form {
                typeSection
                amountSection
                categorySection
                dateSection
                noteSection
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveTransaction() }
                        .font(.body.weight(.semibold))
                        .disabled(!viewModel.isValid)
                }
            }
        }
    }

    // MARK: - Sections

    private var typeSection: some View {
        Section {
            Picker("Type", selection: $viewModel.selectedType) {
                Text("Expense").tag(TransactionType.expense)
                Text("Income").tag(TransactionType.income)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: viewModel.selectedType) { _ in
                viewModel.onTypeChanged()
            }
        }
    }

    private var amountSection: some View {
        Section(header: Text("Amount")) {
            TextField("0.00", text: $viewModel.amountText)
                .keyboardType(.decimalPad)
                .font(.title2)
        }
    }

    private var categorySection: some View {
        Section(header: Text("Category")) {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 80))
            ], spacing: 12) {
                ForEach(viewModel.availableCategories) { category in
                    categoryCell(category)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func categoryCell(_ category: TransactionCategory) -> some View {
        let isSelected = viewModel.selectedCategory == category
        return VStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.title3)
                .foregroundColor(isSelected ? .white : category.color)
                .frame(width: 44, height: 44)
                .background(isSelected ? category.color : category.color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(category.displayName)
                .font(.caption2)
                .foregroundColor(isSelected ? .primary : .secondary)
                .lineLimit(1)
        }
        .onTapGesture {
            viewModel.selectedCategory = category
        }
    }

    private var dateSection: some View {
        Section(header: Text("Date")) {
            DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
        }
    }

    private var noteSection: some View {
        Section(header: Text("Note (optional)")) {
            TextField("Add a note...", text: $viewModel.note)
        }
    }

    // MARK: - Actions

    private func saveTransaction() {
        guard let transaction = viewModel.buildTransaction() else { return }
        onSave(transaction)
        dismiss()
    }
}

#Preview("Add Transaction") {
    AddTransactionView(onSave: { _ in })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
