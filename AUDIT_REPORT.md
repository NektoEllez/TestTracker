# FinanceTracker iOS App – Audit Report

**Date:** March 4, 2026  
**Deployment target:** iOS 15.1  
**Swift:** 5.0, Approachable Concurrency, MainActor default isolation

---

## 1. Architecture & Structure

| Aspect | Status | Details |
|--------|--------|---------|
| **MVVM** | Good | ViewModels separate from Views |
| **Module layout** | Good | Features/, Core/, Shared/ |
| **Dependencies** | Mixed | Protocols for ConfigService, TransactionStore; AppStorageManager singleton |
| **Coordinator** | Good | BrowserCoordinator for WKWebView lifecycle |
| **DI** | Partial | Convenience inits use .shared |

**Recommendations:** Inject AppStorageManager/ConfigService for testability.

---

## 2. Swift / SwiftUI Patterns

| Issue | Severity | Details |
|------|----------|---------|
| **ObservableObject** | Medium | Uses ObservableObject; @Observable (iOS 17+) preferred |
| **NavigationView** | High | Deprecated; migrate to NavigationStack (iOS 16+) |
| **Task.sleep(nanoseconds)** | Low | Prefer Task.sleep(for: .seconds(...)) |
| **.task** | Good | Used correctly for async work |

---

## 3. Security

| Issue | Severity | Details |
|------|----------|---------|
| **NSAllowsArbitraryLoadsInWebContent** | High | Allows HTTP in WebView; required per spec |
| **UserDefaults** | Medium | URLs in UserDefaults; Keychain for sensitive data |
| **Input validation** | Good | AmountInputValidator, AppConfig URL validation |

---

## 4. Performance

| Issue | Severity | Details |
|------|----------|---------|
| **DateFormatter** | Good | Static cached formatters |
| **Currency formatter** | Medium | threadDictionary; consider actor cache |
| **LazyVStack** | Good | Used in lists |
| **loadData()** | Medium | Decoding on main thread |

---

## 5. Error Handling

| Issue | Severity | Location |
|------|----------|----------|
| **Force unwrap** | Critical | RootViewModel group.next()! |
| **try?** | High | Multiple files; errors discarded |
| **view!** | High | DotRefreshScrollView hostingController.view! |
| **preconditionFailure** | Medium | TransactionStore Documents directory |

---

## 6. Module Flow

- ConfigService fetches JSON → extracts URL → ModuleDecision saves to UserDefaults
- RootViewModel: saved decision or fetch with 6s timeout → finance fallback
- Browser: fallback on didFail, didFailProvisional, Access Restricted page, 15s timeout

---

## 7. Code Quality

- File sizes under 300 lines
- Clear naming, MARK sections
- Minor duplication (mappedColorScheme)

---

## 8. Actionable Items

### Critical
1. RootViewModel: Replace `group.next()!` with safe unwrapping

### High
2. Replace NavigationView with NavigationStack
3. Replace DotRefreshScrollView `view!` with safe unwrapping

### Medium
4. Migrate to @Observable
5. Replace try? with do/catch where errors matter
6. Move loadData() decoding off main actor

### Low
7. Task.sleep(for: .seconds(...))
8. Extract mappedColorScheme
