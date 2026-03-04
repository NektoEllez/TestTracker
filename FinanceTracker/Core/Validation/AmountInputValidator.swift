import Foundation

enum AmountValidationError: LocalizedError, Equatable {
    case empty
    case invalidFormat
    case mustBeGreaterThanZero
    case tooLarge(maxAllowed: Decimal)

    var errorDescription: String? {
        switch self {
        case .empty:
            return "Amount is required."
        case .invalidFormat:
            return "Enter a valid amount (up to 2 decimals)."
        case .mustBeGreaterThanZero:
            return "Amount must be greater than 0."
        case .tooLarge(let maxAllowed):
            return "Amount is too large. Max allowed is \(maxAllowed)."
        }
    }
}

enum AmountInputValidator {
    static let maxIntegerDigits = 9
    static let maxFractionDigits = 2
    static let maxAmount = Decimal(string: "999999999.99") ?? 999_999_999.99

    static func sanitize(_ input: String, locale: Locale = .current) -> String {
        let decimalSeparator = locale.decimalSeparator ?? "."
        let normalized = input.replacingOccurrences(of: ",", with: ".")

        var filtered = ""
        var hasSeparator = false

        for character in normalized {
            if character.isWholeNumber {
                filtered.append(character)
            } else if character == ".", !hasSeparator {
                hasSeparator = true
                filtered.append(character)
            }
        }

        guard !filtered.isEmpty else { return "" }

        let parts = filtered.split(separator: ".", omittingEmptySubsequences: false)
        var integerPart = String(parts.first ?? "")
        var fractionPart = parts.count > 1 ? String(parts[1]) : ""

        if integerPart.count > maxIntegerDigits {
            integerPart = String(integerPart.prefix(maxIntegerDigits))
        }
        integerPart = integerPart.trimmingLeadingZerosPreservingSingleZero()

        if fractionPart.count > maxFractionDigits {
            fractionPart = String(fractionPart.prefix(maxFractionDigits))
        }

        let hasDecimalPart = filtered.contains(".")
        if hasDecimalPart {
            if integerPart.isEmpty {
                integerPart = "0"
            }
            return "\(integerPart)\(decimalSeparator)\(fractionPart)"
        }

        return integerPart
    }

    static func parseAmount(from input: String, locale: Locale = .current) -> Decimal? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let decimalSeparator = locale.decimalSeparator ?? "."
        let normalized = trimmed
            .replacingOccurrences(of: decimalSeparator, with: ".")
            .replacingOccurrences(of: ",", with: ".")

        guard normalized != "." else { return nil }

        if let value = Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX")) {
            return value
        }
        return Decimal(string: normalized)
    }

    static func validationError(for input: String, locale: Locale = .current) -> AmountValidationError? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .empty }

        guard let amount = parseAmount(from: trimmed, locale: locale) else {
            return .invalidFormat
        }

        guard amount > .zero else {
            return .mustBeGreaterThanZero
        }

        if amount > maxAmount {
            return .tooLarge(maxAllowed: maxAmount)
        }

        return nil
    }
}

private extension String {
    func trimmingLeadingZerosPreservingSingleZero() -> String {
        guard !isEmpty else { return self }
        let withoutLeadingZeros = drop { $0 == "0" }
        if withoutLeadingZeros.isEmpty {
            return "0"
        }
        return String(withoutLeadingZeros)
    }
}
