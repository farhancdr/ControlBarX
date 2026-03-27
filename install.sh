#!/bin/bash
set -e

APP_NAME="ControlBarX"
DMG_URL="https://github.com/farhancdr/ControlBarX/releases/latest/download/ControlBarX.dmg"
TMP_DMG="/tmp/${APP_NAME}.dmg"
MOUNT_POINT="/tmp/${APP_NAME}_mount"
INSTALL_DIR="/Applications"

echo "Installing ${APP_NAME}..."

# Download latest release
echo "Downloading latest release..."
curl -fSL "$DMG_URL" -o "$TMP_DMG"

# Mount DMG
echo "Mounting DMG..."
hdiutil attach "$TMP_DMG" -nobrowse -mountpoint "$MOUNT_POINT" -quiet

# Copy app to Applications
echo "Copying to ${INSTALL_DIR}..."
rm -rf "${INSTALL_DIR}/${APP_NAME}.app"
cp -R "${MOUNT_POINT}/${APP_NAME}.app" "${INSTALL_DIR}/"

# Unmount and clean up
hdiutil detach "$MOUNT_POINT" -quiet
rm -f "$TMP_DMG"

# Remove quarantine flag
xattr -cr "${INSTALL_DIR}/${APP_NAME}.app"

echo ""
echo "${APP_NAME} installed successfully!"
echo ""
echo "Next steps:"
echo "  1. Open ${APP_NAME} from Applications"
echo "  2. Go to System Settings > Privacy & Security > Accessibility"
echo "  3. Toggle ${APP_NAME} on"
