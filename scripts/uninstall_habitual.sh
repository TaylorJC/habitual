#!/usr/bin/env bash

# Remove the icon and .desktop files
rm ~/.local/share/icons/habitual_icon.png
rm ~/.local/share/applications/habitual.desktop

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo -n "Delete this folder? (y/n): "
echo
read response

if [[ "${response}" = "Y" || "${response}" = "y" || "${response}" = "yes" ]]; then
    rm -r "${SCRIPT_DIR}"
fi
