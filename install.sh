function die() {
	exit 1
}

old=$1
new=$2
kver="$(realpath "$new")"
kver="$(basename "$kver")"
kver="${kver#linux-}"
umask 022
export MAKEFLAGS="-j9"
cp "$old"/.config "$new"/.config || die
cd "$new" || die
rm ../config || die
ln .config ../config || die
make olddefconfig || die
make || die
eselect kernel set linux-"$kver" || die
emerge -v @module-rebuild || die
make modules_install || die
cp arch/x86/boot/bzImage /boot/EFI/EFI/Linux/vmlinuz.efi || die
dracut --kver "$kver" --zstd --no-hostonly --ro-mnt --add "bash zfs" --force "/boot/EFI/EFI/Linux/initramfs.img" || die
