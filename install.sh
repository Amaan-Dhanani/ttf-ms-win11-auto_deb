tmp=$(mktemp -d) && cd "$tmp" && \
wget https://archlinuxgr.tiven.org/archlinux/x86_64/ttf-ms-win11-auto-10.0.26100.1742-4-any.pkg.tar.zst && \
tar -I zstd -xf *.pkg.tar.zst && \
mkdir -p ms-win11-fonts/DEBIAN ms-win11-fonts/usr/share/fonts && \
cp -r usr/share/fonts/* ms-win11-fonts/usr/share/fonts/ && \
printf "Package: ms-win11-fonts
Version: 10.0.26100.1742-4
Section: fonts
Priority: optional
Architecture: all
Maintainer: Converted from Arch
Description: Microsoft Windows 11 fonts repackaged from Arch Linux
" > ms-win11-fonts/DEBIAN/control && \
chmod 755 ms-win11-fonts/DEBIAN && \
chmod 644 ms-win11-fonts/DEBIAN/control && \
dpkg-deb --build ms-win11-fonts && \
sudo dpkg -i ms-win11-fonts.deb && \
sudo fc-cache -fv && \
cd "$OLDPWD" && \
rm -rf "$tmp" && \
echo "DONE: Fonts installed and ready to use"