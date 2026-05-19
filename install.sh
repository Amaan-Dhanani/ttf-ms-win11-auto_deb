#!/usr/bin/env bash
set -euo pipefail

# URL for the Windows ISO
ISO_URL="https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"

# Paths
ISO="$HOME/Downloads/win11.iso"         # persistent ISO location
WORKDIR=$(mktemp -d)                    # temporary working folder
WIM="$WORKDIR/install.wim"
FONTS="$WORKDIR/fonts"
TARGET="/usr/share/fonts/ms-win11"

cleanup() {
    rm -rf "$WORKDIR"
}
trap cleanup EXIT

echo "[*] Installing dependencies..."
sudo apt update
sudo apt install -y wget p7zip-full wimtools fontconfig

mkdir -p "$FONTS" "$TARGET"

# Download ISO only if it doesn't exist
if [[ ! -f "$ISO" ]]; then
    echo "[*] Downloading Windows ISO..."
    wget -O "$ISO" "$ISO_URL"
else
    echo "[*] Using cached ISO at $ISO"
fi

# Extract only install.wim from ISO
echo "[*] Extracting install.wim from ISO..."
7z e "$ISO" "sources/install.wim" -o"$WORKDIR" -y >/dev/null

# Extract only the fonts from install.wim
echo "[*] Extracting fonts from install.wim..."
wimlib-imagex extract "$WIM" 1 /Windows/Fonts "$FONTS"

# Copy fonts to system folder
echo "[*] Installing fonts..."
sudo cp -u "$FONTS/"* "$TARGET/"  # -u = copy only if newer

# Update font cache
echo "[*] Updating font cache..."
sudo fc-cache -f "$TARGET"

echo "[+] Done! Windows fonts installed successfully."