#!/usr/bin/env bash
set -euo pipefail

COVERAGE=false
DOCS=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --coverage) COVERAGE=true; shift ;;
    --docs) DOCS=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

command -v flutter >/dev/null 2>&1 || { echo "Flutter is required in PATH"; exit 1; }

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
APP_DIR="$REPO_ROOT/app"

pushd "$APP_DIR" >/dev/null
echo "Resolving dependencies..."
flutter pub get

echo "Running tests..."
if [ "$COVERAGE" = true ]; then
  flutter test --coverage -r expanded
  echo "Coverage file: $APP_DIR/coverage/lcov.info"
else
  flutter test -r expanded
fi

if [ "$DOCS" = true ]; then
  echo "Generating API docs (dartdoc)..."
  if command -v dart >/dev/null 2>&1; then
    dart doc
  else
    flutter pub run dartdoc
  fi
  echo "Docs generated at: $APP_DIR/doc/api/index.html"
fi

popd >/dev/null

