FROM ghcr.io/cgwalters/fedora-silverblue:37
RUN rpm-ostree install \
    # sign git tags for releases
    git-evtag \
    # local debug tools 
    htop ripgrep  \
    # kerberos auth
    krb5-workstation \
    # run local qemu vms
    libvirt-daemon-config-network libvirt-daemon-kvm qemu-kvm util-linux-user \
    virt-install virt-manager virt-viewer \
    # dev tools
    make xsel \
    # preffered tools
    zsh neofetch \
    # logitech mouse/keyboard pairing
    solaar \
    #cleanup and verification stage
    && rm -rf /var/lib/unbound \
    && ostree container commit
