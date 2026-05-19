#!/usr/bin/env bash
set -euo pipefail

ISO_URL="https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
ISO="$HOME/Downloads/win11.iso"
TARGET="/usr/share/fonts/ms-win11"
WORKDIR=$(mktemp -d)
FONTS="$WORKDIR/fonts"

cleanup() {
    rm -rf "$WORKDIR"
}
trap cleanup EXIT

echo "[*] Installing dependencies..."
sudo apt update
sudo apt install -y wget wimtools fontconfig p7zip-full

mkdir -p "$FONTS" "$TARGET"

# Download ISO only if missing
if [[ ! -f "$ISO" ]]; then
    echo "[*] Downloading Windows ISO..."
    wget -O "$ISO" "$ISO_URL"
else
    echo "[*] Using cached ISO at $ISO"
fi

echo "[*] Extracting fonts directly from ISO..."
# Stream install.wim from ISO to wimlib-imagex
7z e "$ISO" "sources/install.wim" -so | wimlib-imagex extract - "$FONTS" /Windows/Fonts

echo "[*] Installing fonts..."
sudo cp -u "$FONTS/"* "$TARGET/"

echo "[*] Updating font cache..."
sudo fc-cache -f "$TARGET"

echo "[+] Done! Fonts installed ultra-fast."