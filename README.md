# RogueOS

RogueOS is a developer-friendly Debian-based live distribution with optional installer.
It uses the official `live-build` tool chain and targets fast reproducible builds
inside Docker or directly on a Debian/Ubuntu host.

## Requirements
* Debian/Ubuntu host with `sudo`
* ~10 GB free disk space
* Docker (optional for container build)

## Quick start
Build directly on the host:
```sh
make iso
```

Build inside Docker for maximum reproducibility:
```sh
make docker-iso
```
The resulting ISO is placed in `out/rogueos-amd64-YYYYMMDD.iso`.

## Booting with QEMU
```sh
qemu-system-x86_64 -m 2G -cdrom out/rogueos-amd64-$(date +%Y%m%d).iso -enable-kvm
```

## Persistence
Run `scripts/enable_persistence.sh` from a live session to create a persistent
storage area on the boot medium. It sets up a partition or file labeled
`RogueOS` and updates kernel parameters accordingly.

## Installing to disk
Execute `sudo scripts/install_to_disk.sh` from the live session. The script
will partition the target drive, copy the live system and install GRUB for both
BIOS and UEFI. After installation it runs post-install hardening.

## Package buckets
Packages are split into lists under `config/packages.d`. Enable or remove
buckets by editing these files. The combined package list used by live-build is
regenerated each time `build.sh` runs.

## Troubleshooting
* **Secure boot:** secure boot is not enabled by default. Disable it or sign
the kernel and bootloader manually.
* **Missing firmware:** add firmware packages to `config/packages.d/firmware.list` if
hardware requires them.
* **Fast rebuild:** run `make clean` to remove previous build artifacts.

## License
MIT

Booting with QEMU (UEFI)
Install OVMF and use this command to test UEFI boot locally:
qemu-system-x86_64 -m 2G -enable-kvm
-drive if=virtio,format=raw,file=out/rogueos-amd64-$(date +%Y%m%d).iso,media=cdrom
-bios /usr/share/OVMF/OVMF_CODE.fd

CI builds
Every push and pull request builds the ISO in GitHub Actions and uploads it as an artifact under the Actions tab.
