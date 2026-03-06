#!/usr/bin/env bash

# Project quality gate for FinanceTracker.
# Modes:
#   fast   - swiftlint + gitleaks
#   full   - swiftlint + gitleaks + xcode static analyzer
#   strict - same as full, but SwiftLint warnings are treated as errors

set -euo pipefail

MODE="${1:-fast}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_PATH="$ROOT_DIR/.swiftlint.yml"
PROJECT_PATH="$ROOT_DIR/FinanceTracker.xcodeproj"
SCHEME_NAME="FinanceTracker"
DESTINATION="generic/platform=iOS Simulator"

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo -e "${RED}❌ Missing required command: $1${NC}"
    exit 1
  fi
}

run_swiftlint() {
  require_command swiftlint
  if [[ ! -f "$CONFIG_PATH" ]]; then
    echo -e "${RED}❌ SwiftLint config not found: $CONFIG_PATH${NC}"
    exit 1
  fi

  echo "▶ SwiftLint (project-wide)"
  if [[ "$MODE" == "strict" ]]; then
    swiftlint lint --strict --config "$CONFIG_PATH"
  else
    swiftlint lint --config "$CONFIG_PATH"
  fi
}

run_gitleaks() {
  if ! command -v gitleaks >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️ gitleaks not installed, skipping secret scan (brew install gitleaks).${NC}"
    return
  fi

  echo "▶ gitleaks (repo scan)"
  gitleaks detect --source "$ROOT_DIR" --no-banner --redact
}

run_analyzer() {
  require_command xcodebuild
  echo "▶ Xcode static analyzer"
  xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME_NAME" \
    -configuration Debug \
    -destination "$DESTINATION" \
    analyze \
    CODE_SIGNING_ALLOWED=NO
}

print_usage_and_exit() {
  echo "Usage: ./scripts/quality-gate.sh [fast|full|strict]"
  exit 1
}

case "$MODE" in
  fast)
    run_swiftlint
    run_gitleaks
    ;;
  full)
    run_swiftlint
    run_gitleaks
    run_analyzer
    ;;
  strict)
    run_swiftlint
    run_gitleaks
    run_analyzer
    ;;
  *)
    print_usage_and_exit
    ;;
esac

echo -e "${GREEN}✅ Quality gate passed (${MODE}).${NC}"
