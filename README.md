# rodin build

打包与刷写工具：把 org/linux 的产物 + initramfs 仓的产物组装成可刷镜像，并用 fastboot 写入设备。

## 输入约定

| 产物 | 来源 |
|---|---|
| `Image.lz4`（上限 60 MiB）、`dtb.img` | org/linux（M1 起产出） |
| `initramfs.cpio.gz` | initramfs 仓 |
| `vbmeta.img` | 官方 ROM 提取（TODO(M0) 固化获取方式） |

## 用法

```sh
scripts/mkboot.sh -k Image.lz4 -d dtb.img -i initramfs.cpio.gz
scripts/flash.sh a        # 刷 _a（Ubuntu 试验槽）：boot + vendor_boot + vbmeta(disable-verity/verification) + set_active
```

`_b` 是 6.18 oracle 槽，`flash.sh` 拒绝写 b，除非显式 `--force`。

## 硬约束

- **dtbo / 固件分区一律不刷**（有启动校验）
- 页大小 / cmdline / board 等基线参数 TODO(M0)：从 6.18 oracle 的刷机流程记录后固化进 `mkboot.sh`

## 许可

MIT（详见 LICENSE）。
