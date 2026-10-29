#!/usr/bin/env bash
# 组包 boot.img + vendor_boot.img（boot header v4）
# 用法: mkboot.sh -k Image.lz4 -d dtb.img -i initramfs.cpio.gz [-o outdir]
#
# 约束：dtbo / 固件分区一律不碰（有启动校验）——本脚本只产 boot / vendor_boot。
set -euo pipefail

KERNEL= DTB= INITRAMFS= OUT=.
while getopts "k:d:i:o:" x; do case "$x" in
    k) KERNEL=$OPTARG ;;
    d) DTB=$OPTARG ;;
    i) INITRAMFS=$OPTARG ;;
    o) OUT=$OPTARG ;;
    *) echo "usage: $0 -k Image.lz4 -d dtb.img -i initramfs.cpio.gz [-o outdir]" >&2; exit 1 ;;
esac; done
: "${KERNEL:?-k Image.lz4 required}" "${DTB:?-d dtb.img required}" "${INITRAMFS:?-i initramfs.cpio.gz required}"
mkdir -p "$OUT"

# TODO(M0)：从 6.18 oracle 的刷机基线固化以下参数，先给占位值
PAGE_SIZE=4096
BOARD=rodin
CMDLINE=""   # M0 定稿：console / pstore 相关参数进这里

MKBOOTIMG=${MKBOOTIMG:-mkbootimg}   # AOSP tools/mkbootimg（python3）

"$MKBOOTIMG" --header_version 4 \
    --kernel "$KERNEL" \
    --page_size "$PAGE_SIZE" --board "$BOARD" --cmdline "$CMDLINE" \
    --output "$OUT/boot.img"

"$MKBOOTIMG" --header_version 4 \
    --vendor_boot "$OUT/vendor_boot.img" \
    --vendor_ramdisk "$INITRAMFS" \
    --dtb "$DTB" \
    --page_size "$PAGE_SIZE" --board "$BOARD"

echo "OK: $OUT/boot.img  $OUT/vendor_boot.img"
