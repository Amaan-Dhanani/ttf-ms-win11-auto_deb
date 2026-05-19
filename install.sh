#!/usr/bin/env bash
set -euo pipefail

ISO_URL="https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"

WORKDIR=$(mktemp -d)
ISO="$WORKDIR/win.iso"
MNT="$WORKDIR/mnt"
FONTDIR="/usr/share/fonts/ms-win11"

cleanup() {
    echo "[*] Cleaning up..."
    sudo umount "$MNT" 2>/dev/null || true
    [[ -n "${LOOPDEV:-}" ]] && sudo losetup -d "$LOOPDEV" 2>/dev/null || true
    rm -rf "$WORKDIR"
}
trap cleanup EXIT

echo "[*] Installing dependencies..."
sudo apt update
sudo apt install -y wget p7zip-full util-linux fontconfig

mkdir -p "$MNT"

echo "[*] Downloading ISO (once)..."
wget -O "$ISO" "$ISO_URL"

echo "[*] Mounting ISO..."
sudo mount -o loop "$ISO" "$MNT"

echo "[*] Extracting fonts from install.wim..."
mkdir -p "$WORKDIR/fonts"

# correct approach: extract from WIM, not ISO stream
7z e "$MNT/sources/install.wim" -o"$WORKDIR/fonts" "*.ttf" "*.ttc" -r >/dev/null

echo "[*] Installing fonts..."
sudo mkdir -p "$FONTDIR"
sudo cp "$WORKDIR/fonts/"* "$FONTDIR/" 2>/dev/null || true

echo "[*] Updating font cache..."
sudo fc-cache -f "$FONTDIR"

echo "[+] Fonts installed successfully!"