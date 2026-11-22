#!/bin/zsh
# Build an unsigned local DMG for testing/distribution to yourself.
# For public distribution without Gatekeeper warnings, use Developer ID signing + notarization.
set -euo pipefail
cd "$(dirname "$0")"
./build.sh
mkdir -p dist
rm -f dist/Snowhush.dmg
hdiutil create -volname "Snowhush" \
  -srcfolder build/Snowhush.app \
  -ov -format UDZO \
  dist/Snowhush.dmg

echo "Created: $(pwd)/dist/Snowhush.dmg"
