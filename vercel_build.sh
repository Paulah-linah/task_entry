#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.24.2"

echo "Installing Flutter ${FLUTTER_VERSION}..."
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter
fi

export PATH="$PWD/flutter/bin:$PATH"

flutter --version

echo "Fetching dependencies..."
flutter pub get

echo "Building Flutter web..."
flutter build web --release
