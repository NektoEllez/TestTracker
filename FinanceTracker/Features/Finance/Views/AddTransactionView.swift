import SwiftUI
import UIKit

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddTransactionViewModel()
    @State private var saveErrorMessage: String?
    @FocusState private var focusedField: InputField?
    
    let onSave: (Transaction) throws -> Void
    
    private enum InputField: Hashable {
        case amount
        case note
    }
    
    var body: some View {
        NavigationView {
            Form {
                typeSection
                amountSection
                currencySection
                categorySection
                dateSection
                noteSection
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismissForm() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveTransaction() }
                        .font(.body.weight(.semibold))
                        .disabled(!viewModel.isValid)
                }
            }
        }
        .alert("Unable to Save", isPresented: Binding(
            get: { saveErrorMessage != nil },
            set: { if !$0 { saveErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { saveErrorMessage = nil }
        } message: {
            Text(saveErrorMessage ?? "Please try again.")
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
                Haptics.selection()
                viewModel.onTypeChanged()
            }
        }
    }
    
    private var amountSection: some View {
        Section(header: Text("Amount")) {
            TextField("0.00", text: amountInputBinding)
                .keyboardType(.decimalPad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .font(.title2)
                .focused($focusedField, equals: .amount)
            
            Text("Currency: \(viewModel.selectedCurrencyCode)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let error = viewModel.amountErrorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var amountInputBinding: Binding<String> {
        Binding(
            get: { viewModel.amountText },
            set: { newValue in
                viewModel.amountText = AmountInputValidator.sanitize(newValue)
            }
        )
    }
    
    private var currencySection: some View {
        Section(header: Text("Currency")) {
            Picker("Currency", selection: $viewModel.selectedCurrencyCode) {
                ForEach(CurrencyCatalog.popular) { option in
                    Text(option.title).tag(option.code)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: viewModel.selectedCurrencyCode) { newCode in
                Haptics.selection()
                viewModel.setCurrencyCode(newCode)
            }
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
            Haptics.selection()
            viewModel.selectedCategory = category
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(category.displayName)
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
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
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .focused($focusedField, equals: .note)
            
            HStack {
                Spacer()
                Text("\(viewModel.note.count)/\(viewModel.noteLimit)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveTransaction() {
        focusedField = nil
        dismissKeyboard()
        guard let transaction = viewModel.buildTransaction() else { return }
        do {
            try onSave(transaction)
            dismiss()
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }
    
    private func dismissForm() {
        focusedField = nil
        dismissKeyboard()
        dismiss()
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview("Add Transaction") {
    AddTransactionView(onSave: { _ in })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
