FROM quay.io/fedora/fedora-kinoite:40
RUN mkdir /workdir
WORKDIR /workdir
COPY . .
# First install bootc and dnf until Fedora 41...
RUN rpm-ostree install bootc dnf5 && ln -s /usr/bin/dnf5 /usr/bin/dnf && \
    dnf -y install \
    # sign git tags for releases
    git-evtag pinentry \
    # local debug tools 
    htop ripgrep  \
    # kerberos auth
    krb5-workstation \
    # run local qemu vms
    libvirt-daemon-config-network libvirt-daemon-kvm qemu-kvm \
    virt-install virt-manager virt-viewer \
    # dev tools
    make xsel strace \
    # preffered tools
    util-linux-user nu tmux neovim \
    # logitech mouse/keyboard pairing & apple superdrive
    solaar sg3_utils && \
    # Add nu to shells
    echo "nu" >> /etc/shells && \
    # Mount rules for apple external dvd drive
    mv 99-local.rules /etc/udev/rules.d/ && \
    # cleanup and verification stage
    rm -rf /var/lib/unbound && rm -rf /workdir && ostree container commit
