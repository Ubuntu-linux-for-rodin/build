#!/usr/bin/env bash
# 刷写：只写 Ubuntu 试验槽 _a；_b 为 6.18 oracle 槽（防误刷，--force 才放行）。
# 硬约束：绝不刷 dtbo / 固件分区（有启动校验）。
set -euo pipefail

SLOT=${1:-a}
FORCE=0
[ "${2:-}" = "--force" ] && FORCE=1

case "$SLOT" in
    a) ;;
    b) [ "$FORCE" -eq 1 ] || {
           echo "refuse: _b 是 6.18 oracle 槽（fastboot set_active b 即可切回）。确要覆盖请: $0 b --force"
           exit 1
       } ;;
    *) echo "usage: $0 {a|b} [--force]"; exit 1 ;;
esac

IMAGEDIR=${IMAGEDIR:-.}
BOOT="$IMAGEDIR/boot.img"
VBOOT="$IMAGEDIR/vendor_boot.img"
VBMETA="$IMAGEDIR/vbmeta.img"   # TODO(M0)：从官方 ROM 提取

for f in "$BOOT" "$VBOOT"; do
    [ -f "$f" ] || { echo "missing: $f（先用 mkboot.sh 组包）"; exit 1; }
done

echo "将写入 slot _${SLOT}: boot / vendor_boot / vbmeta(--disable-verity --disable-verification)，并 set_active。"
read -rp "继续? [y/N] " yn
[ "$yn" = "y" ] || exit 1

fastboot flash boot_"$SLOT" "$BOOT"
fastboot flash vendor_boot_"$SLOT" "$VBOOT"
if [ -f "$VBMETA" ]; then
    fastboot flash vbmeta_"$SLOT" "$VBMETA" --disable-verity --disable-verification
else
    echo "warn: $VBMETA 不存在，跳过 vbmeta（设备此前已 disable 过则无碍）"
fi
fastboot set_active "$SLOT"
echo "完成。切回 6.18 oracle：fastboot set_active b"
