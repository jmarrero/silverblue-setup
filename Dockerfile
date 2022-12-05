FROM ghcr.io/cgwalters/fedora-silverblue:37
#Add vscode repo
#RUN echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/code.repo
RUN rpm-ostree install \
    # sign git tags for releases
 #   git git-evtag \
    # local debug tools 
  #  htop ripgrep  \
    # kerberos auth
    krb5-workstation \
    # run local qemu vms
   # libvirt-daemon-config-network libvirt-daemon-kvm qemu-kvm util-linux-user \
    #virt-install virt-manager virt-viewer \
    # dev tools
    #make xsel \
    # preffered tools
    zsh \
    #neofetch \
    # logitech mouse/keyboard pairing
    solaar \
    # third party
    #code \
    #cleanup and verification stage
    #&& rm -rf /var/lib/unbound \
    && ostree container commit
