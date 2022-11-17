This is my current silverblue setup using OSTree Native Container.

This builds the ./Dockerfile with podman and dockerx for debugging purposes.

They are pushed to:
`ghcr.io/jmarrero/jmarrero-silverblue:latest`
and
`ghcr.io/jmarrero/jmarrero-silverblue:docker-latest`

The base image I use currently comes from:
https://github.com/cgwalters/sync-fedora-ostree-containers

There is also an example of building the zfs kernel module under `zfs-test` module. However for updated examples look at:
https://github.com/coreos/coreos-layering-examples

CoreOS layering examples should work with Silverblue by chaging the base image.
