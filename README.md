This is my Fedora Kinoite 45 bootc setup (Bootable Containers) for a
2013 Mac Pro 6,1.

The image includes the RPM Fusion Broadcom `wl` driver for the Mac Pro's
BCM4360 (`14e4:43a0`) Wi-Fi adapter. The module is built against the exact
kernel contained in the image during the container build.

The setup builds the ./Containerfile using buildah.

The resulting build is pushed to:
ghcr.io/jmarrero/bootc-macpro61tc:latest
