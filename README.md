# FinanceTracker

Мобильное iOS-приложение для учета личных финансов.

**Работает на iOS 15.1+** — поддерживает старые устройства.

## Что есть в приложении

- экран запуска с анимацией;
- онбординг (показывается только при необходимости);
- основной экран учета доходов и расходов:
  - сводные карточки;
  - диаграмма;
  - история операций с подгрузкой;
  - добавление новой операции;
- встроенный веб-экран для внешнего контента.

## Технологии

- Swift, SwiftUI;
- iOS 15.1+;
- Swift Package Manager;
- DGCharts (донат/пирог-диаграммы).

## Запуск

1. Открыть `FinanceTracker.xcodeproj` в Xcode.
2. Выбрать схему `FinanceTracker`.
3. Запустить на симуляторе или устройстве с iOS 15.1+.

## Quality Gate (Lint + Security + Analyzer)

Перед commit/push можно запускать единый скрипт:

```bash
./scripts/quality-gate.sh fast
```

- `fast`: SwiftLint по всему проекту + gitleaks (поиск секретов).

```bash
./scripts/quality-gate.sh full
```

- `full`: всё из `fast` + `xcodebuild analyze` (статический анализ Xcode).

```bash
./scripts/quality-gate.sh strict
```

- `strict`: как `full`, но SwiftLint warnings трактуются как ошибки.

Рекомендация:
- перед обычным commit: `fast`
- перед merge/push в `main`: `full` или `strict`

### Автозапуск перед commit/push

Чтобы проверки запускались автоматически:

```bash
./scripts/install-local-hooks.sh
```

Что это включает:
- `pre-commit`: глобальный `~/.githooks/pre-commit` + `./scripts/quality-gate.sh fast`
- `pre-push`: `./scripts/quality-gate.sh full`
