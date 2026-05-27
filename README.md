# Modular Dotfiles & FPGA Tool Containers

A modular, cross-platform dotfiles repository designed to run consistently on a Debian host, inside development containers, and on vendor VMs without configuration drift or breakage.

---

## 📂 Repository Structure

The repository is structured to separate core global configurations from OS-specific or host-specific settings:

```
├── bootstrap.sh                 # Zero-dependency entrypoint for fresh installations
├── install.sh                   # Second-stage configuration orchestrator
├── core/                        # Pure POSIX shell, editor, & tool configs (OS-agnostic)
│   ├── bash/                    # Bash profile, rc, and rc.d snippets
│   ├── zsh/                     # Zsh oh-my-zsh integration
│   ├── common/                  # Shared aliases, exports, functions (~/.config/shell)
│   ├── nvim/                    # LazyVim editor configurations
│   └── tmux/                    # Tmux terminal multiplexing config
├── os/                          # OS-specific packages stowed dynamically
│   ├── debian/                  # Debian package shortcuts & aliases
│   ├── ubuntu/                  # Ubuntu snaps & apt profiles
│   └── almalinux/               # AlmaLinux/RHEL dnf profile overrides
├── host/                        # Machine-specific directories
│   ├── debian-laptop/           # Laptop battery & display profiles
│   └── debian-workstation/      # Workstation computation & GPU options
├── scripts/                     # Installer sub-scripts & utilities
│   ├── fpga/                    # FPGA Tool (Vivado/JTAG) configurations
│   └── ...
└── tests/                       # Multi-OS test environment setups
```

---

## 🚀 How to Install & Bootstrap

You can bootstrap this repository in a fresh environment (Debian/Ubuntu, AlmaLinux, or macOS) with one command.

### Local Installation / Bootstrapping
Clone this repository and run the entrypoint script:
```bash
cd ~/dotfiles
./bootstrap.sh
```

`bootstrap.sh` performs the following actions:
1. Detects your OS family and native package manager (`apt-get`, `dnf`, or `brew`).
2. Configures AlmaLinux EPEL repositories if stowing tools are missing.
3. Installs minimal dependencies (`git`, `stow`, `curl`, `python3`).
4. Invokes the second stage (`install.sh`), which:
   - Configures default feature flags in `~/.dotfiles.local`.
   - Runs helper scripts to install dependencies and Homebrew.
   - Symlinks configurations dynamically using `stow --no-folding` (preventing directory folding conflicts).

---

## 🛠️ Feature Flags

We use feature flags inside `~/.dotfiles.local` to adapt configurations to different contexts (e.g., GUI desktops vs. headless servers or FPGA containers) without duplicating profiles:

*   `DOTFILES_FEATURE_GUI=1|0`: Controls graphical settings. If set to `0` (default in headless terminals or Docker), it skips heavy operations like Nerd Font installations.
*   `DOTFILES_FEATURE_FPGATOOLS=1|0`: Activates toolchain profiles, paths, and environment settings.

To tweak flags, edit `~/.dotfiles.local` on your machine:
```bash
export DOTFILES_FEATURE_GUI=1
export DOTFILES_FEATURE_FPGATOOLS=0
```

---

## 🐳 Container Testing Matrix

The scripts are rigorously verified across a multi-distribution test matrix.

To build and run smoke tests on all container targets, run:
```bash
./build_test_containers.sh --all
```

Supported test environments:
*   `debian:stable`
*   `ubuntu:latest`
*   `almalinux:10`

---

## ⚡ FPGA & Vivado Container Integration

We provide specialized support to run heavy FPGA vendor tools (like Vivado 2025.2) inside a dedicated container with JTAG and GUI forwarding.

All files are located in `scripts/fpga/`:
*   `Dockerfile.vivado`: A base Ubuntu 24.04 image containing X11 graphics libraries, JTAG dependencies, and an automatic checkout of your bootstrapped dotfiles for a seamless terminal experience.
*   `launch_vivado.sh`: Launches your Vivado container:
    - Automatically enables X11 display socket sharing (`DISPLAY` & `/tmp/.X11-unix`).
    - Maps USB controller buses (`/dev/bus/usb` with `--privileged`) for JTAG programmers.
    - Mounts `/opt/fpga-tools` from your host to keep container sizes small and toolchains versioned on the host disk.
    - Aligns user UID/GIDs to prevent file permission clashes.
*   `test_jtag.sh`: Diagnostics script to scan host USB controllers for Xilinx (03fd) or Digilent (0403) JTAG cables, inspect rules under `/etc/udev/rules.d/`, and test permissions.
