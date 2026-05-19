#!/bin/bash
set -e
cd "$(dirname "$0")"

swift build -c release

ARCH=$(uname -m)
BUILD=".build/${ARCH}-apple-macosx/release"
APP="Neko.app"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"

cp "$BUILD/Neko" "$APP/Contents/MacOS/Neko"

if [ -d "$BUILD/Neko_Neko.bundle" ]; then
  cp -r "$BUILD/Neko_Neko.bundle" "$APP/Contents/Resources/"
fi

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key>  <string>com.neko.app</string>
  <key>CFBundleName</key>        <string>Neko</string>
  <key>CFBundleVersion</key>     <string>1</string>
  <key>CFBundleExecutable</key>  <string>Neko</string>
  <key>LSUIElement</key>         <true/>
  <key>NSHighResolutionCapable</key> <true/>
</dict>
</plist>
PLIST

echo "✓ Neko.app lista — doble clic para lanzar."
