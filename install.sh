#!/bin/bash
# Builds and copies the app to /Applications, then launches it.
set -euo pipefail
cd "$(dirname "$0")"
./build.sh
pkill -x Procrastination 2>/dev/null || true
rm -rf /Applications/Procrastination.app
cp -R build/Procrastination.app /Applications/
open /Applications/Procrastination.app
