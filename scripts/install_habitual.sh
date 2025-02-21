#!/usr/bin/env bash

# Copy the icon to the local share folder
cp ./data/flutter_assets/assets/habitual_icon.png ~/.local/share/icons/habitual_icon.png

# Get this directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Create the .desktop file
echo "[Desktop Entry]
Name=Habitual
Version=1.1
Type=Application
Categories=Application
Comment=A minimalist habit tracker
Exec=${SCRIPT_DIR}/Habitual
Icon=habitual_icon.png
Terminal=false" >> ~/.local/share/applications/habitual.desktop

chmod +x ~/.local/share/applications/habitual.desktop
