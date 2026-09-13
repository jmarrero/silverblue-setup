#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run this script with sudo: sudo ./iso/build.sh" >&2
    exit 1
fi

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo"
payload_image=${PAYLOAD_IMAGE:-ghcr.io/jmarrero/bootc-macpro61tc:latest}
builder_image=${BUILDER_IMAGE:-ghcr.io/osbuild/image-builder-cli:latest}
installer_image=localhost/macpro-installer:latest
output="$repo/output/iso-$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$output/installer-context"

finish() {
    if [[ -n ${SUDO_UID:-} && -n ${SUDO_GID:-} ]]; then
        chown -R "$SUDO_UID:$SUDO_GID" "$output"
    fi
}
trap finish EXIT
exec > >(tee "$output/build.log") 2>&1
echo "Build output: $output"

for tool in podman python3 sha256sum; do
    command -v "$tool" >/dev/null || { echo "Missing required command: $tool"; exit 1; }
done
[[ $(uname -m) == x86_64 ]] || { echo 'This installer targets x86_64.'; exit 1; }

# Reuse the published OS image. Only the installer environment is built here.
# Pull into the root-owned Podman store that image-builder uses below.
podman pull "$payload_image"
podman image inspect "$payload_image" --format '{{.Id}}' > "$output/payload-image-id.txt"

python3 iso/make-config.py > "$output/installer-context/iso.yaml"
cp iso/Containerfile iso/anaconda.conf "$output/installer-context/"
# Use the host network so package downloads can reach the host's DNS resolver.
podman build --network=host --file "$output/installer-context/Containerfile" \
    --build-arg "PAYLOAD_IMAGE=$payload_image" \
    --tag "$installer_image" "$output/installer-context"

# All images must be in the same root-owned Podman store as image-builder.
podman pull "$builder_image"
podman run --rm "$builder_image" version > "$output/builder-version.txt"
storage=$(podman info --format '{{.Store.GraphRoot}}')
podman run --rm --privileged --security-opt label=disable \
    --volume "$output:/output" \
    --volume "$storage:/var/lib/containers/storage" \
    "$builder_image" build \
    --bootc-ref "$installer_image" \
    --bootc-installer-payload-ref "$payload_image" \
    --bootc-default-fs ext4 \
    --with-manifest --with-buildlog \
    bootc-generic-iso

mapfile -d '' images < <(find "$output" -maxdepth 2 -type f -name '*.iso' -print0)
if [[ ${#images[@]} -ne 1 ]]; then
    echo "Expected one ISO, found ${#images[@]}; see $output/build.log" >&2
    exit 1
fi
iso_file="$output/bootc-macpro61tc-x86_64.iso"
mv "${images[0]}" "$iso_file"

# Verify the actual ISO's boot menu, rather than just its input configuration.
podman run --rm --entrypoint xorriso \
    --volume "$output:/output" "$installer_image" \
    -osirrox on -indev /output/bootc-macpro61tc-x86_64.iso \
    -extract /boot/grub2/grub.cfg /output/grub.cfg
python3 - "$output" <<'PY'
import json
from pathlib import Path
import sys
output = Path(sys.argv[1])
config = json.loads((output / 'installer-context/iso.yaml').read_text())
grub = (output / 'grub.cfg').read_text()
for arg in config['grub2']['entries'][0]['linux'].split()[1:]:
    if arg not in grub:
        raise SystemExit(f'ISO boot menu is missing: {arg}')
print('Verified installer kernel arguments in the generated ISO.')
PY
(
    cd "$output"
    sha256sum bootc-macpro61tc-x86_64.iso > SHA256SUMS
)
echo "ISO ready: $iso_file"
