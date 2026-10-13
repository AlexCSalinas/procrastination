#!/bin/bash
# Builds Procrastination.app into ./build and ad-hoc signs it.
set -euo pipefail
cd "$(dirname "$0")"
swift build -c release
APP=build/Procrastination.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp "$(swift build -c release --show-bin-path)/Procrastination" "$APP/Contents/MacOS/"
cp Resources/Info.plist "$APP/Contents/Info.plist"
codesign --force --sign - "$APP"
echo "Built $APP  (run: open $APP, or ./install.sh)"
