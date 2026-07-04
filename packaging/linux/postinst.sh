#!/bin/sh
# postinst script for FastSM
set -e

APP_NAME="FastSM"

case "$1" in
    configure|abort-upgrade|abort-remove|abort-deconfigure)
        # Update desktop database
        if command -v update-desktop-database >/dev/null 2>&1; then
            update-desktop-database 2>/dev/null || true
        fi

        # Update icon cache if there's a hicolor icon
        if command -v gtk-update-icon-cache >/dev/null 2>&1; then
            gtk-update-icon-cache -f -q /usr/share/icons/hicolor 2>/dev/null || true
        fi
        ;;
esac

exit 0
