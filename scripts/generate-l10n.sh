#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
XCSTRINGS="$REPO_ROOT/Packages/CoreUI/Sources/CoreUI/Resources/Localizable.xcstrings"
OUTPUT="$REPO_ROOT/Packages/CoreUI/Sources/CoreUI/Localization/L10n.swift"

python3 "$REPO_ROOT/scripts/generate-l10n.py" "$XCSTRINGS" "$OUTPUT"
