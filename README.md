<p align="center">
  <a href="https://openimages.cloud/images/arch-linux/">
    <img src="https://openimages.cloud/img/og/arch-linux.png" alt="Arch Linux cloud image for OpenStack and Proxmox" width="720">
  </a>
</p>

<p align="center">
  <a href="https://openimages.cloud/images/arch-linux/"><img alt="Latest version" src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fimages.openimages.cloud%2Farch-linux%2Flatest%2FMANIFEST.json&query=%24.version&label=latest&color=2459c4&cacheSeconds=3600"></a>
  <a href="https://github.com/open-img-cloud/arch-linux/actions/workflows/release.yml"><img alt="Release" src="https://github.com/open-img-cloud/arch-linux/actions/workflows/release.yml/badge.svg"></a>
  <a href="https://openimages.cloud/verify/"><img alt="Signed with Sigstore cosign" src="https://img.shields.io/badge/signed-Sigstore%20cosign-2459c4"></a>
  <a href="https://openimages.cloud/quality/"><img alt="Boot-tested on OpenStack" src="https://img.shields.io/badge/boot--tested-OpenStack-2459c4"></a>
  <a href="LICENSE"><img alt="License GPL-2.0" src="https://img.shields.io/badge/license-GPL--2.0-555"></a>
</p>

<p align="center">
  <a href="https://openimages.cloud/images/arch-linux/"><b>Catalog page</b></a> ·
  <a href="https://images.openimages.cloud/arch-linux/latest/">Download</a> ·
  <a href="https://openimages.cloud/verify/">Verify</a> ·
  <a href="https://github.com/open-img-cloud/docs">Documentation</a> ·
  <a href="https://github.com/open-img-cloud/arch-linux/issues">Report an issue</a>
</p>

Arch Linux cloud image (qcow2) for **OpenStack** and **Proxmox**: the official Arch Linux
`cloudimg` image built by [arch-boxes](https://gitlab.archlinux.org/archlinux/arch-boxes),
verified, made ready for both clouds with the same rules as every
[openimages.cloud](https://openimages.cloud) image, signed with Sigstore cosign and boot-tested
on a real OpenStack before it is published. Arch Linux is a rolling release: an image is a
snapshot of the repositories on its build date, so run `pacman -Syu` after the first boot.

## At a glance

| | |
|---|---|
| **Upstream** | [Arch Linux](https://archlinux.org/) `cloudimg` image from [geo.mirror.pkgbuild.com](https://geo.mirror.pkgbuild.com/images/), checked against its `.SHA256` file |
| **Default user** | `arch`, SSH key only, passwordless `sudo` |
| **Firmware** | BIOS (the disk also carries an EFI system partition) |
| **Format** | qcow2, x86_64, Btrfs root filesystem grown to the disk at first boot |
| **Version** | `<build date>.<build id>`, the upstream arch-boxes build, e.g. `20261101.620452` ([all versions](https://images.openimages.cloud/arch-linux/versions.json)) |
| **Support** | Rolling release, no end of life; upstream images are built twice a month |

## Quick start

```sh
# Latest version and its file name, from the signed manifest
M=https://images.openimages.cloud/arch-linux/latest/MANIFEST.json
V=$(curl -fsS $M | jq -r .version); F=$(curl -fsS $M | jq -r .filename)
curl -fLO https://images.openimages.cloud/arch-linux/$V/$F
```

<details>
<summary><b>OpenStack</b></summary>

```sh
openstack image create --disk-format qcow2 --container-format bare \
  --property os_distro=arch \
  --property hw_qemu_guest_agent=yes --property os_admin_user=arch \
  --file "$F" "Arch Linux"
```

The full property set (SCSI disk, multiqueue, quiesced snapshots) is on the
[catalog page](https://openimages.cloud/images/arch-linux/) and in
[`index.json`](https://images.openimages.cloud/index.json). To keep images up to date
automatically, use [oic-sync](https://github.com/open-img-cloud/oic-sync).

</details>

<details>
<summary><b>Proxmox VE</b></summary>

The commands to create a cloud-init template from this image are on the
[catalog page](https://openimages.cloud/images/arch-linux/).

</details>

<details>
<summary><b>Verify the signature</b></summary>

```sh
curl -fLO https://images.openimages.cloud/arch-linux/$V/$F.bundle
cosign verify-blob "$F" --bundle "$F.bundle" \
  --certificate-identity-regexp '^https://github.com/open-img-cloud/\.github/\.github/workflows/build-(libguestfs|dib|nix-flake|freebsd)-image\.yml@' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

</details>

## What this image changes

The official image already ships cloud-init, `qemu-guest-agent` and a serial console. On top of it, and nothing else:

- adds the openimages.cloud cloud-init policy: config drive read first, then the metadata
  service; no root login, no SSH password;
- cleans package caches and machine identity so every instance starts fresh (the pacman
  keyring is still created at first boot, as upstream intends).

Every release must pass the same [runtime contract](https://openimages.cloud/quality/) on
OpenStack: SSH with the injected key, cloud-init finished, DNS, hostname, root filesystem grown,
passwordless `sudo`, IPv6 address and egress.

## How releases happen

1. Every day at 07:29 UTC a watcher looks for a new upstream image and opens a pull request
   that bumps [`VERSION`](VERSION).
2. Merging it is all it takes: the release is tagged, built, signed, boot-tested and
   published, then `latest/` and the [catalog](https://openimages.cloud/images/) move to it.

This repository only holds what is specific to Arch Linux: [`VERSION`](VERSION),
[`build/customize.sh`](build/customize.sh), [`build/detect-upstream.sh`](build/detect-upstream.sh)
and thin workflows calling the shared pipeline in
[`open-img-cloud/.github`](https://github.com/open-img-cloud/.github).

## License

The build tooling in this repository is under [GPL-2.0](LICENSE). The image keeps the licensing
terms of Arch Linux (free software under the license of each package). Arch Linux and the Arch
Linux logo are trademarks of Levente Polyák and Judd Vinet on behalf of Arch Linux, used here
under the [Arch Linux trademark policy](https://terms.archlinux.org/docs/trademark-policy/) to
refer to the unmodified upstream image; this project is not affiliated with, approved or
sponsored by Arch Linux.
