# Code Review: FinanceTracker

**Дата:** 4 марта 2026  
**Область:** UUID/String, типичные джунские ошибки, архитектура, SwiftUI, Swift Concurrency

---

## Содержание

1. [UUID и идентификаторы](#1-uuid-и-идентификаторы)
2. [Force unwrap и try?](#2-force-unwrap-и-try)
3. [Архитектура и паттерны](#3-архитектура-и-паттерны)
4. [SwiftUI и state management](#4-swiftui-и-state-management)
5. [Производительность и форматтеры](#5-производительность-и-форматтеры)
6. [Безопасность и секреты](#6-безопасность-и-секреты)
7. [Рекомендации по исправлению](#7-рекомендации-по-исправлению)

---

## 1. UUID и идентификаторы

### 1.1. Transaction — UUID как публичный ID доменной модели

**Файл:** `Core/Models/Transaction.swift`

```swift
struct Transaction: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    ...
    init(id: UUID = UUID(), ...)
}
```

**Проблема:** Для персистентных сущностей использование сырого `UUID` как публичного ID усложняет:
- версионирование API (бэкенд может ожидать строку);
- миграции и экспорт/импорт;
- тестирование (сложнее подставлять детерминированные ID).

**Рекомендация:** Ввести типизированный ID-обёртку:

```swift
struct TransactionID: Hashable, Codable, Sendable {
    let value: String

    init() { self.value = UUID().uuidString }
    init(_ value: String) { self.value = value }
}

struct Transaction: Codable, Identifiable, Equatable, Sendable {
    let id: TransactionID
    ...
}
```

В JSON хранить `id` как строку. Протокол `TransactionStoreProtocol` и `TransactionStore` перевести на `TransactionID`.

---

### 1.2. ChartSegment — нестабильный ID при каждом пересчёте

**Файл:** `Features/Finance/Charts/ChartSegment.swift`

```swift
struct ChartSegment: Identifiable {
    let id = UUID()
    let category: TransactionCategory
    ...
}
```

**Проблема:** Сегменты строятся из `expenseByCategory` при каждом обновлении. `id = UUID()` даёт новый ID при каждом пересчёте → SwiftUI не может сопоставить старые и новые элементы. Это ломает анимации, диффинг и может вызывать мерцание.

**Рекомендация:** Использовать детерминированный ID по категории:

```swift
struct ChartSegment: Identifiable, Hashable {
    let category: TransactionCategory
    let amount: Double
    let percentage: Double
    let startAngle: Double
    let endAngle: Double

    var id: String { category.rawValue }
    var color: Color { category.color }
    var label: String { category.displayName }
}
```

---

### 1.3. OnboardingPage — UUID для статического контента

**Файл:** `Core/Models/OnboardingPage.swift`

```swift
struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    ...
}
```

**Оценка:** Здесь `static let pages` создаётся один раз, ID стабильны. Для статического контента UUID допустим, но избыточен. Лучше использовать индекс или строковый идентификатор:

```swift
struct OnboardingPage: Identifiable {
    let id: String  // или Int
    let imageName: String
    let title: String
    let description: String

    init(id: String, imageName: String, title: String, description: String) { ... }
}

static let pages: [OnboardingPage] = [
    OnboardingPage(id: "track", imageName: "chart.pie.fill", ...),
    ...
]
```

---

### 1.4. TransactionGroup — Date как ID

**Файл:** `Features/Finance/ViewModels/FinanceViewModel.swift`

```swift
struct TransactionGroup: Identifiable, Sendable {
    let id: Date
    let date: Date
    let transactions: [Transaction]
}
```

**Оценка:** `Date` как ID для группировки по дню — разумный выбор, стабилен и детерминирован. Замечаний нет.

---

## 2. Force unwrap и try?

### 2.1. TransactionStore — force unwrap для documentsDirectory

**Файл:** `Core/Persistence/TransactionStore.swift`

```swift
init() {
    let documentsDirectory = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first!
    self.fileURL = documentsDirectory.appendingPathComponent("transactions.json")
}
```

**Проблема:** `first!` может крашить при нестандартной конфигурации (тесты, симулятор). Типичная джунская ошибка — «это же всегда есть».

**Рекомендация:**

```swift
init() {
    guard let documentsDirectory = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first else {
        fatalError("Documents directory not available")
    }
    self.fileURL = documentsDirectory.appendingPathComponent("transactions.json")
}
```

Или лучше — инжектировать `fileURL` через инициализатор для тестируемости.

---

### 2.2. RootView — try? без обработки

**Файл:** `Features/Root/RootView.swift`

```swift
.task {
    try? await Task.sleep(nanoseconds: 1_500_000_000)
    await viewModel.determineModule()
}
```

**Проблема:** `try?` глушит отмену Task. При отмене `.task` `Task.sleep` бросает `CancellationError`, и `try?` это скрывает. Логика продолжит выполняться после отмены.

**Рекомендация:**

```swift
.task {
    try? await Task.sleep(for: .seconds(1.5))
    await viewModel.determineModule()
}
```

Или явно обработать отмену:

```swift
.task {
    do {
        try await Task.sleep(for: .seconds(1.5))
    } catch is CancellationError {
        return
    }
    await viewModel.determineModule()
}
```

Также: использовать `Task.sleep(for: .seconds(1.5))` вместо `nanoseconds` — читаемее.

---

### 2.3. Transaction — try? при декодировании amount

**Файл:** `Core/Models/Transaction.swift`

```swift
if let decimalAmount = try? container.decode(Decimal.self, forKey: .amount) {
    amount = decimalAmount
} else {
    let legacyDouble = try container.decode(Double.self, forKey: .amount)
    amount = Decimal(legacyDouble)
}
```

**Оценка:** Здесь `try?` используется осознанно для fallback на `Double`. Это допустимо, но лучше явно ловить `DecodingError` и логировать, если нужна отладка миграций.

---

### 2.4. ConfigService — preconditionFailure

**Файл:** `Core/Services/ConfigService.swift`

```swift
guard let url = URL(string: rawURLString) else {
    preconditionFailure("ConfigURL is invalid")
}
```

**Оценка:** Для конфигурации при старте приложения `preconditionFailure` допустим. Альтернатива — бросать кастомную ошибку и обрабатывать её в `AppDelegate`/корне приложения.

---

### 2.5. AppConfig — try? для JSONSerialization

**Файл:** `Core/Models/AppConfig.swift`

```swift
guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
    return nil
}
```

**Оценка:** Возврат `nil` при невалидном JSON — нормальная стратегия для «мягкого» парсинга конфига. Замечаний нет.

---

## 3. Архитектура и паттерны

### 3.1. ObservableObject вместо @Observable

**Файлы:** `FinanceViewModel`, `AddTransactionViewModel`, `RootViewModel`, `WebViewModel`

```swift
@MainActor
final class FinanceViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    ...
}
```

**Проблема:** В iOS 17+ рекомендуется `@Observable` + `@State`/`@Bindable`. `ObservableObject`/`@StateObject`/`@ObservedObject` — legacy.

**Рекомендация:**

```swift
@Observable
@MainActor
final class FinanceViewModel {
    var transactions: [Transaction] = []
    var showingAddTransaction = false
    ...
}
```

Во вью: `@State private var viewModel = FinanceViewModel()` и `@Bindable` при необходимости биндингов.

---

### 3.2. NavigationView вместо NavigationStack

**Файлы:** `FinanceContainerView`, `AddTransactionView`

```swift
NavigationView { ... }
.navigationViewStyle(StackNavigationViewStyle())
```

**Проблема:** `NavigationView` deprecated в iOS 16+. Нужен `NavigationStack`.

**Рекомендация:**

```swift
NavigationStack {
    ...
}
```

---

### 3.3. Синхронный loadData в init

**Файл:** `Features/Finance/ViewModels/FinanceViewModel.swift`

```swift
init(store: TransactionStoreProtocol) {
    self.store = store
    loadData()
}
```

**Проблема:** Синхронная загрузка в `init` блокирует main thread. Для файлового хранилища это может быть приемлемо, но при переходе на сеть или тяжёлый диск — проблема.

**Рекомендация:** Загружать в `.task` или отдельном `load()` при появлении экрана.

---

### 3.4. Жёсткая привязка к TransactionStore

**Файл:** `FinanceContainerView.swift`

```swift
@StateObject private var viewModel = FinanceViewModel()
```

`FinanceViewModel()` создаёт `TransactionStore()` внутри. Нет инжекции зависимостей → сложнее тестировать и подменять хранилище.

**Рекомендация:** Инжектировать `TransactionStoreProtocol` через окружение или инициализатор.

---

## 4. SwiftUI и state management

### 4.1. .cornerRadius вместо .clipShape

**Файлы:** `FinanceScreen`, `FinanceContainerView`, `SummaryCardsView`

```swift
.cornerRadius(16)
.cornerRadius(12)
```

**Проблема:** `.cornerRadius` deprecated. Рекомендуется `.clipShape(RoundedRectangle(cornerRadius: 16))`.

---

### 4.2. onAppear вместо .task для async

**Файл:** `FinanceContainerView.swift`

```swift
.onAppear {
    OrientationManager.shared.lockPortrait()
}
```

**Оценка:** Здесь нет async-логики, `onAppear` уместен. Для загрузки данных лучше `.task`.

---

### 4.3. Размер body

**Файл:** `FinanceScreen.swift`

`body` разбит на `summarySection`, `chartSection`, `transactionsSection` — хорошо. Дополнительно можно вынести `chartSection` в отдельный компонент.

---

### 4.4. Магические числа

**Примеры:**
- `padding(.bottom, 80)` — «Space for FAB»
- `frame(width: 200, height: 200)` в DonutChartView
- `lineWidth: 32`
- `padding(.horizontal, 16)`, `padding(.vertical, 14)`

**Рекомендация:** Вынести в константы или `enum Layout { ... }`.

---

## 5. Производительность и форматтеры

### 5.1. NumberFormatter в hot path

**Файл:** `Shared/Extensions/Double+Currency.swift`

```swift
func formattedCurrency(...) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    ...
    return formatter.string(from: ...) ?? "$0"
}
```

**Проблема:** Создание `NumberFormatter` при каждом вызове дорого. В списке транзакций и чартах это вызывается часто.

**Рекомендация:** Использовать общий статический форматтер:

```swift
private static let currencyFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .currency
    f.currencyCode = "USD"
    return f
}()

func formattedCurrency(code: String = "USD", maximumFractionDigits: Int) -> String {
    let formatter = Self.currencyFormatter
    formatter.currencyCode = code
    formatter.maximumFractionDigits = maximumFractionDigits
    return formatter.string(from: NSNumber(value: self)) ?? "$0"
}
```

---

### 5.2. DateFormatter в Date+Formatting

**Файл:** `Shared/Extensions/Date+Formatting.swift`

Каждое обращение к `mediumFormatted`, `shortDayMonth`, `sectionTitle` создаёт новый `DateFormatter`. Лучше кэшировать или использовать статические экземпляры.

---

### 5.3. AddTransactionViewModel — NumberFormatter при каждом parsedAmount

**Файл:** `Features/Finance/ViewModels/AddTransactionViewModel.swift`

`parsedAmount` создаёт новый `NumberFormatter` при каждом обращении. Можно вынести в `lazy` или статический форматтер.

---

## 6. Безопасность и секреты

### 6.1. ConfigService — fallback URL в коде

**Файл:** `Core/Services/ConfigService.swift`

```swift
static let fallbackConfigURLString = "https://drive.google.com/uc?export=download&id=13935lF1Cs8cRQOYRp6pnkK-TalBW5EyU"
```

**Оценка:** Публичный URL, не секрет. Для production лучше хранить в Info.plist или конфиге, не хардкодить.

---

### 6.2. UserDefaults для ModuleDecision

**Файл:** `Core/Models/ModuleDecision.swift`

Используются строковые ключи `"module_decision_type"`, `"module_decision_url"`. Для UserDefaults это нормально. Для чувствительных данных — не подходит (Keychain).

---

## 7. Рекомендации по исправлению

### Приоритет 1 (критично)

| # | Проблема | Файл | Статус |
|---|----------|------|--------|
| 1 | ChartSegment нестабильный UUID | ChartSegment.swift | ✅ Исправлено (`id: category.rawValue`) |
| 2 | TransactionStore `.first!` | TransactionStore.swift | ✅ Исправлено (`guard let`) |
| 3 | RootView `try?` при Task.sleep | RootView.swift | ⚠️ Оставлен `nanoseconds` (iOS 15.1 target; `Task.sleep(for:)` требует iOS 16+) |

### Приоритет 2 (рекомендуется)

| # | Проблема | Файл | Статус |
|---|----------|------|--------|
| 4 | Transaction → TransactionID | Transaction.swift, Store | ✅ Исправлено (типизированный `TransactionID`) |
| 5 | ObservableObject → @Observable | ViewModels | Отложено |
| 6 | NavigationView → NavigationStack | FinanceContainerView, AddTransactionView | ⚠️ Отложено (требует iOS 16+; проект на 15.1) |
| 7 | .cornerRadius → .clipShape | Несколько Views | Используется `.appGlassSurface` / `.clipShape` |

### Приоритет 3 (улучшения)

| # | Проблема | Действие |
|---|----------|----------|
| 8 | NumberFormatter/DateFormatter в hot path | Кэшировать статические экземпляры |
| 9 | Магические числа | Вынести в константы |
| 10 | DI для TransactionStore | Инжектировать через Environment или init |

---

## Итог

Проект в целом структурирован, разбиение на Features/Core/Shared логичное. Основные зоны роста:

1. **Идентификаторы:** стабильные ID для SwiftUI (`ChartSegment`), типизированные ID для домена (`Transaction`).
2. **Безопасность кода:** убрать force unwrap, аккуратно обрабатывать `try?` и отмену Task.
3. **Современный стек:** `@Observable`, `NavigationStack`, `clipShape`.
4. **Производительность:** переиспользование форматтеров в горячих путях.
