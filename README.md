This is my Fedora Kinoite 45 bootc setup (Bootable Containers) for a
2013 Mac Pro 6,1.

The image includes the RPM Fusion Broadcom `wl` driver for the Mac Pro's
BCM4360 (`14e4:43a0`) Wi-Fi adapter. The module is built against the exact
kernel contained in the image during the container build.

The setup builds the ./Containerfile using buildah.

The resulting build is pushed to:
ghcr.io/jmarrero/bootc-macpro61tc:latest

## Build an installer ISO locally

Run from this checkout on an x86_64 Linux host with Podman and Python 3.11+:

```bash
sudo ./iso/build.sh
```

The script pulls the published `ghcr.io/jmarrero/bootc-macpro61tc:latest` OS
image, then builds a separate Fedora 45 Anaconda environment and packages
both into an offline installer using
`ghcr.io/osbuild/image-builder-cli:latest`. It uses root-owned Podman storage
for every stage. Docker images and images pulled with rootless Podman are
in separate stores, so the script pulls the OS image into root-owned Podman
storage. It does not rebuild the OS. Allow tens of gigabytes of free space
for the installer build and ISO.

The installer container build uses host networking for package downloads,
avoiding DNS failures in Podman's isolated build network.

The resulting ISO, `SHA256SUMS`, logs, builder version, OS image ID, and build
manifest are saved under `output/iso-<UTC timestamp>/`. The script checks the
kernel arguments in the finished ISO's GRUB configuration. Nothing is
published to a registry. After installation, the OS follows
`ghcr.io/jmarrero/bootc-macpro61tc:latest` for updates.

The installer kernel arguments are generated from all x86_64-applicable
`usr/lib/bootc/kargs.d/*.toml` files. They currently include:

```text
radeon.si_support=0 radeon.cik_support=0 amdgpu.si_support=1 amdgpu.cik_support=1 amdgpu.dc=1
```

The published OS supplies its own kernel arguments; keep this checkout's
`kargs.d` files in sync with that image. The installer also needs `inst.stage2` and Anaconda's live
boot options. Its `selinux=0` setting follows the upstream installer example
and does not disable SELinux in the installed OS.

No account file or password is needed before building. Anaconda's account
screen is explicitly enabled: choose your username and password during
installation and make the account an administrator (the `wheel` group).
The installed root account is locked. Disk selection and partitioning are
interactive. The Broadcom `wl` driver is included in the installed OS;
the separate installer uses Fedora's standard drivers and does not need
Wi-Fi to install the embedded payload.

Verify the download/build before writing the ISO to USB:

```bash
cd output/iso-<timestamp>
sha256sum -c SHA256SUMS
```

A successful ISO build is not a boot test. Test the installer in a UEFI VM
and on the Mac Pro before relying on it.

References: [Image Builder's generic ISO instructions](https://osbuild.org/docs/developer-guide/projects/image-builder/advanced/bootc/isos/),
[bootc kernel arguments](https://bootc.dev/bootc/building/kernel-arguments.html),
and [bootc account provisioning](https://bootc.dev/bootc/building/users-and-groups.html).
