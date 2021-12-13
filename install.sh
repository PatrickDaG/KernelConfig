old=$1
new=$2
kver="$(realpath "$new")"
kver="$(basename "$kver")"
kver="${kver#linux-}"
umask 022
export MAKEFLAGS="-j9"
cp "$old"/.config "$new"/.config
cd "$new"
rm ../config
ln .config ../config
make olddefconfig
make
eselect kernel set linux-"$kver"
emerge -v @module-rebuild
make modules_install
cp arch/x86/boot/bzImage /boot/EFI/EFI/Linux/vmlinuz.efi
dracut --conf "/dev/null" --confdir "/dev/null" --kver "$kver" --zstd --no-hostonly --ro-mnt --add "bash zfs" --force "/boot/EFI/EFI/Linux/initramfs.img"
