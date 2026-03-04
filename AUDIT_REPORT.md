# Audit Report — FinanceTracker

**Дата:** 4 марта 2026

## Выполненные исправления

### 1. AppDelegate — Navigation Bar
- Добавлен `configureNavigationBarAppearance()` в `didFinishLaunchingWithOptions`
- Navigation bar использует `systemGroupedBackground`, убрана тень
- Единый вид для `standardAppearance`, `scrollEdgeAppearance`, `compactAppearance`

### 2. Производительность — форматтеры
- **Double+Currency:** `NumberFormatter` вынесен в статический `CurrencyFormatting.sharedFormatter` (переиспользование вместо создания при каждом вызове)
- **Date+Formatting:** `DateFormatter` для `mediumFormatted` и `shortDayMonth` вынесены в статические экземпляры

### 3. Info.plist
- Добавлен `UIRequiresFullScreen = true` для полноэкранного режима

### 4. Уже исправлено ранее (проверено)
- **Transaction:** типизированный `TransactionID` (String)
- **ChartSegment:** детерминированный `id: category.rawValue`
- **TransactionStore:** `guard let` вместо `first!`, throwing API

---

## Отложено / не требуется

| Пункт | Причина |
|-------|---------|
| NavigationView → NavigationStack | Требует iOS 16+; проект на 15.1 |
| Task.sleep CancellationError | `.task` ожидает non-throwing closure; `try?` оставлен |
| ObservableObject → @Observable | Требует iOS 17+; масштабная миграция |

---

## Рекомендации на будущее

1. **NSAppTransportSecurity:** `NSAllowsArbitraryLoads = true` — ослабляет ATS. Для WebView с произвольными URL это может быть необходимо; рассмотреть `NSExceptionDomains` для конкретных доменов.
2. **Миграция на iOS 16+:** после повышения deployment target — перейти на `NavigationStack`, `Task.sleep(for:)`.
3. **Миграция на iOS 17+:** рассмотреть `@Observable` вместо `ObservableObject`.
