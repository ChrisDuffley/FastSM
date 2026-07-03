#!/bin/bash
# Build .deb and .rpm packages from a PyInstaller Linux build output.
#
# Usage:
#   ./packaging/linux/build_packages.sh <dist_dir> <version> [output_dir]
#
#   dist_dir    - Path to the PyInstaller output directory (e.g. ~/app_dist/FastSM/dist/FastSM)
#   version     - Version string (e.g. 0.5.0)
#   output_dir  - Where to write the packages (default: current directory)
#
# Requires: fpm (effing package management)
# Install: gem install fpm
#          or  apt-get install ruby-fpm

set -euo pipefail

DIST_DIR="${1:?Usage: $0 <dist_dir> <version> [output_dir]}"
VERSION="${2:?Usage: $0 <dist_dir> <version> [output_dir]}"
OUTPUT_DIR="${3:-$(pwd)}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

APP_NAME="FastSM"
APP_DESCRIPTION="A fast, accessible social media client for Mastodon and Bluesky"
APP_URL="https://github.com/masonasons/FastSM"
APP_VENDOR="Mew"
APP_MAINTAINER="Mew"
APP_LICENSE="All Rights Reserved"
APP_ARCH="amd64"

# Dependencies that the PyInstaller bundle needs at runtime on the host system
DEB_DEPENDS=(
    "libgtk-3-0"
    "libnotify4"
    "libsdl2-2.0-0"
    "libasound2"
    "libpulse0"
    "libgstreamer1.0-0"
    "libgstreamer-plugins-base1.0-0"
)

RPM_DEPENDS=(
    "gtk3"
    "libnotify"
    "SDL2"
    "alsa-lib"
    "pulseaudio-libs"
    "gstreamer1"
    "gstreamer1-plugins-base"
)

# --- Check prerequisites ---
if ! command -v fpm &>/dev/null; then
    echo "fpm is required. Install it with:"
    echo "  gem install fpm"
    echo "  # or"
    echo "  apt-get install ruby-fpm"
    exit 1
fi

if [ ! -d "$DIST_DIR" ]; then
    echo "Error: dist directory not found: $DIST_DIR"
    exit 1
fi

echo "=========================================="
echo "Building Linux packages for $APP_NAME v$VERSION"
echo "=========================================="
echo "Dist dir:  $DIST_DIR"
echo "Output:    $OUTPUT_DIR"
echo

# --- Build Debian package ---
echo "--- Building .deb ---"
fpm \
    --input-type dir \
    --output-type deb \
    --name "$APP_NAME" \
    --version "$VERSION" \
    --architecture "$APP_ARCH" \
    --vendor "$APP_VENDOR" \
    --maintainer "$APP_MAINTAINER" \
    --description "$APP_DESCRIPTION" \
    --url "$APP_URL" \
    --license "$APP_LICENSE" \
    --category "net" \
    --package "$OUTPUT_DIR/${APP_NAME}_${VERSION}_${APP_ARCH}.deb" \
    --force \
    --deb-user root \
    --deb-group root \
    --deb-priority optional \
    --deb-field "Section: net" \
    --verbose \
    $(for d in "${DEB_DEPENDS[@]}"; do echo --depends "$d"; done) \
    "$DIST_DIR=/opt/$APP_NAME" \
    "$PROJECT_DIR/packaging/linux/fastsm.desktop=/usr/share/applications/$APP_NAME.desktop" \
    "$PROJECT_DIR/packaging/debian/copyright=/usr/share/doc/$APP_NAME/copyright" \
    "$PROJECT_DIR/docs/=/usr/share/doc/$APP_NAME/"

echo

# --- Build RPM package ---
echo "--- Building .rpm ---"
fpm \
    --input-type dir \
    --output-type rpm \
    --name "$APP_NAME" \
    --version "$VERSION" \
    --architecture x86_64 \
    --vendor "$APP_VENDOR" \
    --maintainer "$APP_MAINTAINER" \
    --description "$APP_DESCRIPTION" \
    --url "$APP_URL" \
    --license "$APP_LICENSE" \
    --category "Network" \
    --package "$OUTPUT_DIR/${APP_NAME}-${VERSION}-1.x86_64.rpm" \
    --force \
    --rpm-user root \
    --rpm-group root \
    --verbose \
    $(for d in "${RPM_DEPENDS[@]}"; do echo --depends "$d"; done) \
    "$DIST_DIR=/opt/$APP_NAME" \
    "$PROJECT_DIR/packaging/linux/fastsm.desktop=/usr/share/applications/$APP_NAME.desktop" \
    "$PROJECT_DIR/docs/=/usr/share/doc/$APP_NAME/"

echo
echo "=========================================="
echo "Packages created:"
ls -lh "$OUTPUT_DIR/"*.deb "$OUTPUT_DIR/"*.rpm 2>/dev/null || true
echo "=========================================="
