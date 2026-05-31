#!/usr/bin/env bash
set -euo pipefail

# --- auto-detect repo ---
get_repo() {
  local url; url=$(git remote get-url origin 2>/dev/null || true)
  url=${url#*github.com:}; url=${url#*github.com/}; url=${url%.git}
  echo "$url"
}
REPO=${REPO:-$(get_repo)}
[[ -z "$REPO" ]] && { echo "No git remote found"; exit 1; }

[[ -f pubspec.yaml ]] || { echo "Run in Flutter project root"; exit 1; }
VERSION=$(grep -E '^version:' pubspec.yaml | head -1 | awk '{print $2}' | cut -d'+' -f1)

echo "==> Repo: $REPO  Version: $VERSION"

# --- CORE INTEGRITY: CHECK FOR FORGOTTEN VERSION BUMP ---
echo "==> Verifying version bump against GitHub..."
# We use the web JSON as the baseline since Web is built on every OS
JSON_URL="https://github.com/${REPO}/releases/latest/download/update-app-web.json"
TMP_VER=$(mktemp -d)

if curl -sSfL "$JSON_URL" -o "$TMP_VER/update.json" 2>/dev/null; then
    REMOTE_VERSION=$(jq -r '.version' "$TMP_VER/update.json" 2>/dev/null || echo "0.0.0")
    rm -rf "$TMP_VER"

    if [[ "$VERSION" == "$REMOTE_VERSION" ]]; then
        echo "=========================================================="
        echo "❌ ERROR: Local version ($VERSION) matches the live version."
        echo "   Please bump the 'version:' field in your pubspec.yaml!"
        echo "=========================================================="
        exit 1
    fi

    LOWEST=$(printf '%s\n%s' "$VERSION" "$REMOTE_VERSION" | sort -V | head -n1)
    if [[ "$LOWEST" == "$VERSION" ]]; then
        echo "=========================================================="
        echo "❌ ERROR: Local version ($VERSION) is OLDER than the live version ($REMOTE_VERSION)."
        echo "   Please bump the 'version:' field in your pubspec.yaml!"
        echo "=========================================================="
        exit 1
    fi
    echo "  ✓ Version bump verified: Local $VERSION > Remote $REMOTE_VERSION"
else
    rm -rf "$TMP_VER"
    echo "  ⚠ Could not fetch latest remote version (possibly first release). Skipping verification."
fi

OUT_DIR="$(pwd)/release"; mkdir -p "$OUT_DIR"

# --- GENERIC PACKAGER ---
package_target() {
  local name=$1        # e.g., "web", "android", "linux", "windows"
  local source_dir=$2  # e.g., "build/web"

  echo "==> Packaging $name..."

  local STAGE="/tmp/smirror-app-${VERSION}-${name}"
  rm -rf "$STAGE"; mkdir -p "$STAGE"

  # Copy compiled files to staging area
  cp -r "$source_dir/"* "$STAGE/"

  local ZIP_NAME="smirror-app-${VERSION}-${name}.zip"
  local ZIP_PATH="${OUT_DIR}/${ZIP_NAME}"

  # Zip the contents
  ( cd "$STAGE" && zip -9 -r -q "$ZIP_PATH" . )

  local SHA=$(sha256sum "$ZIP_PATH" | awk '{print $1}')
  local SIZE=$(stat -c%s "$ZIP_PATH")
  local TAG="${VERSION}"
  local URL="https://github.com/${REPO}/releases/download/${TAG}/${ZIP_NAME}"

  local JSON_CONSTANT="${OUT_DIR}/update-app-${name}.json"

  # Generate the single, constant JSON manifest
  cat > "$JSON_CONSTANT" <<EOF
{
  "version": "${VERSION}",
  "platform": "${name}",
  "url": "${URL}",
  "sha256": "${SHA}",
  "size": ${SIZE}
}
EOF

  rm -rf "$STAGE"

  echo "  ✓ $ZIP_NAME  (${SIZE} bytes)"
  echo "  ✓ $(basename "$JSON_CONSTANT")"
}

# ==============================================================================
# 1. BUILD WEB (With WASM & Gzip)
# ==============================================================================
echo ""
echo "=========================================="
echo "==> 1. Building Web (WASM)"
echo "=========================================="
# Switched 'flutter' to 'fvm flutter'
fvm flutter build web --release --wasm

# Compress files larger than 1KB, keeping both original and .gz files
echo "==> Applying aggressive Gzip compression..."
find build/web -type f -size +1k \( -name "*.wasm" -o -name "*.js" -o -name "*.mjs" -o -name "*.html" -o -name "*.css" -o -name "*.json" \) -exec gzip -k -f -9 {} \;

package_target "web" "build/web"


# ==============================================================================
# 2. BUILD ANDROID (APK)
# ==============================================================================
echo ""
echo "=========================================="
echo "==> 2. Building Android"
echo "=========================================="
# Switched 'flutter' to 'fvm flutter'
fvm flutter build apk --release

# Stage the APK so it can be cleanly zipped into its own folder
APK_STAGE="/tmp/smirror-apk-stage"
rm -rf "$APK_STAGE"; mkdir -p "$APK_STAGE"
cp build/app/outputs/flutter-apk/app-release.apk "$APK_STAGE/smirror-app.apk"

package_target "android" "$APK_STAGE"
rm -rf "$APK_STAGE"


# ==============================================================================
# 3. BUILD LINUX (Only if running on Linux Host)
# ==============================================================================
echo ""
echo "=========================================="
echo "==> 3. Building Linux"
echo "=========================================="
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Switched 'flutter' to 'fvm flutter'
  fvm flutter build linux --release
  package_target "linux" "build/linux/x64/release/bundle"
else
  echo "⚠ Skipping Linux build (This requires a Linux host machine!)"
fi


# ==============================================================================
# 4. BUILD WINDOWS (Only if running on Windows Host)
# ==============================================================================
echo ""
echo "=========================================="
echo "==> 4. Building Windows"
echo "=========================================="
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
  # Switched 'flutter' to 'fvm flutter'
  fvm flutter build windows --release
  package_target "windows" "build/windows/x64/runner/Release"
else
  echo "⚠ Skipping Windows build (This requires a Windows/MSYS host machine!)"
fi

echo ""
echo "=========================================="
echo "All done! Generated releases are in: $OUT_DIR"
echo "=========================================="
ls -lh "$OUT_DIR"