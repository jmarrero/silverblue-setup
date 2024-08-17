FROM quay.io/fedora/fedora-kinoite:40
# First install bootc and dnf until it's included...
RUN rpm-ostree install bootc dnf5 dnf5-plugins && ln -s /usr/bin/dnf5 /usr/bin/dnf && \
    ## Add vscode repo and key
    rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo' && \
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
    # podman machine and reqs
    podman-gvproxy virtiofsd \
    # dev tools
    make xsel strace \
    # preffered tools
    util-linux-user nu tmux neovim code \
    # logitech mouse/keyboard pairing & apple superdrive
    solaar sg3_utils && \
    # Install podman-bootc thru copr
    dnf -y install 'dnf-command(copr)' && \
    dnf -y copr enable gmaglione/podman-bootc && \
    dnf -y install podman-bootc && \
    ## podman machine workaround on 5.2 until podman-machine subpackage is added...
    ## https://github.com/containers/podman/issues/23127
    dnf -y install https://kojipkgs.fedoraproject.org//packages/podman/5.2.0/1.fc40/x86_64/podman-machine-5.2.0-1.fc40.x86_64.rpm && \
    # Add nu to shells
    echo "/usr/bin/nu" >> /etc/shells