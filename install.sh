#!/usr/bin/env bash
set -euo pipefail

ISO_URL="https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
TARGET_DIR="/usr/share/fonts/ms-win11"

echo "[*] Installing dependencies..."
sudo apt update
sudo apt install -y wget p7zip-full fontconfig

sudo mkdir -p "$TARGET_DIR"

echo "[*] Streaming fonts directly from ISO into $TARGET_DIR..."
# List fonts in the ISO (assuming .ttf/.ttc files)
FONT_LIST=$(wget -qO- "$ISO_URL" | 7z l -si -bd -slt | awk '/Path = /{print $3}' | grep -E '\.(ttf|ttc)$')

for font in $FONT_LIST; do
    echo "[*] Installing $(basename "$font")..."
    wget -qO- "$ISO_URL" | 7z e -si -so "$font" | sudo tee "$TARGET_DIR/$(basename "$font")" >/dev/null
done

echo "[*] Updating font cache..."
sudo fc-cache -f "$TARGET_DIR"

echo "[+] Fonts installed directly."
