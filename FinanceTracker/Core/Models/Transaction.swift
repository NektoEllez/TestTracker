import Foundation

struct TransactionID: Hashable, Codable, Sendable {
    let value: String
    
    init() { value = UUID().uuidString }
    init(_ value: String) { self.value = value }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringID = try? container.decode(String.self) {
            value = stringID
        } else if let legacyUUID = try? container.decode(UUID.self) {
            value = legacyUUID.uuidString
        } else {
            throw DecodingError.typeMismatch(
                TransactionID.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected String or UUID for id")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

struct Transaction: Codable, Identifiable, Equatable, Sendable {
    let id: TransactionID
    let amount: Decimal
    let type: TransactionType
    let category: TransactionCategory
    let date: Date
    let note: String?
    
    init(
        id: TransactionID = TransactionID(),
        amount: Decimal,
        type: TransactionType,
        category: TransactionCategory,
        date: Date = Date(),
        note: String? = nil
    ) {
        self.id = id
        self.amount = amount
        self.type = type
        self.category = category
        self.date = date
        self.note = note
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, amount, type, category, date, note
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(TransactionID.self, forKey: .id)
        type = try container.decode(TransactionType.self, forKey: .type)
        category = try container.decode(TransactionCategory.self, forKey: .category)
        date = try container.decode(Date.self, forKey: .date)
        note = try container.decodeIfPresent(String.self, forKey: .note)
        
        if let decimalAmount = try? container.decode(Decimal.self, forKey: .amount) {
            amount = decimalAmount
        } else {
            let legacyDouble = try container.decode(Double.self, forKey: .amount)
            amount = Decimal(legacyDouble)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(amount, forKey: .amount)
        try container.encode(type, forKey: .type)
        try container.encode(category, forKey: .category)
        try container.encode(date, forKey: .date)
        try container.encodeIfPresent(note, forKey: .note)
    }
}

