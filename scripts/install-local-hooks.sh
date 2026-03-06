#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

git config core.hooksPath .githooks

echo "✅ Local hooks installed for this repo"
echo "   core.hooksPath=$(git config --get core.hooksPath)"
