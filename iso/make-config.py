#!/usr/bin/env python3
"""Generate the installer's GRUB configuration from the OS kernel arguments."""

import json
from pathlib import Path
import sys
import tomllib

repo = Path(__file__).resolve().parent.parent
args = []
for path in sorted((repo / "usr/lib/bootc/kargs.d").glob("*.toml")):
    config = tomllib.loads(path.read_text())
    if "x86_64" not in config.get("match-architectures", ["x86_64"]):
        continue
    for arg in config.get("kargs", []):
        if not isinstance(arg, str) or not arg or any(c.isspace() for c in arg):
            raise ValueError(f"Invalid kernel argument in {path}: {arg!r}")
        if arg not in args:
            args.append(arg)

label = "MacPro-bootc-Installer"
linux = [
    "/images/pxeboot/vmlinuz",
    f"inst.stage2=hd:LABEL={label}",
    "console=tty0",
    "inst.graphical",
    # Matches the upstream Anaconda live-environment example; ISO only.
    "selinux=0",
    "rhgb",
    "quiet",
    *args,
]
config = {
    "label": label,
    "grub2": {
        "entries": [{
            "name": "Install Fedora Kinoite on Mac Pro",
            "linux": " ".join(linux),
            "initrd": "/images/pxeboot/initrd.img",
        }],
    },
}
# JSON is valid YAML, so this needs only Python's standard library.
json.dump(config, sys.stdout, indent=2)
print()
