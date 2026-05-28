#!/usr/bin/env python3
"""Install packages declared in packages/manifest.toml.

Usage:
  python3 packages/install.py [--dry-run] [--group system|brew-build-deps|brew|all]
"""

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

try:
    import tomllib          # Python 3.11+
except ImportError:
    try:
        import tomli as tomllib  # type: ignore[no-redef]
    except ImportError:
        sys.exit(
            "tomllib not found. Requires Python 3.11+, or install:\n"
            "  apt: sudo apt install python3-tomli\n"
            "  pip: pip install tomli"
        )

MANIFEST = Path(__file__).parent / "manifest.toml"
DOTFILES_LOCAL = Path.home() / ".dotfiles.local"


# ── Environment detection ─────────────────────────────────────────────────────

def detect_os() -> str:
    os_release = Path("/etc/os-release")
    if os_release.exists():
        with os_release.open() as f:
            for line in f:
                if line.startswith("ID="):
                    return line.strip().removeprefix("ID=").strip('"')
    if sys.platform == "darwin":
        return "macos"
    return "unknown"


def load_flags() -> dict[str, bool]:
    flags: dict[str, bool] = {"gui": False, "fpga": False}
    if DOTFILES_LOCAL.exists():
        text = DOTFILES_LOCAL.read_text()
        flags["gui"] = "DOTFILES_FEATURE_GUI=1" in text
        flags["fpga"] = "DOTFILES_FEATURE_FPGATOOLS=1" in text
    return flags


# ── Command helpers ───────────────────────────────────────────────────────────

def _elevate(cmd: list[str]) -> list[str]:
    return cmd if os.geteuid() == 0 else ["sudo", *cmd]


def run(cmd: list[str], dry_run: bool) -> None:
    print(f"  $ {' '.join(cmd)}")
    if not dry_run:
        subprocess.run(cmd, check=True)


def apt_install(packages: list[str], dry_run: bool) -> None:
    if not packages:
        return
    run(_elevate(["apt-get", "update", "-y"]), dry_run)
    run(_elevate(["apt-get", "install", "-y"] + packages), dry_run)


def dnf_install(packages: list[str], dry_run: bool) -> None:
    if packages:
        run(_elevate(["dnf", "install", "-y"] + packages), dry_run)


def dnf_groupinstall(group: str, dry_run: bool) -> None:
    run(_elevate(["dnf", "groupinstall", "-y", group]), dry_run)


def brew_install(formulae: list[str], dry_run: bool) -> None:
    if not formulae:
        return
    if not shutil.which("brew"):
        print("  brew not found — skipping formulae.")
        return
    result = subprocess.run(
        ["brew", "list", "--formula"], capture_output=True, text=True
    )
    already = set(result.stdout.split())
    pending = [f for f in formulae if f not in already]
    if not pending:
        print("  All formulae already installed.")
        return
    print(f"  Installing: {', '.join(pending)}")
    run(["brew", "install"] + pending, dry_run)


# ── Group installers ──────────────────────────────────────────────────────────

def install_system(manifest: dict, os_id: str, flags: dict[str, bool], dry_run: bool) -> None:
    sys_cfg = manifest.get("system", {})
    common: list[str] = sys_cfg.get("common", [])

    if os_id in ("debian", "ubuntu"):
        pm = sys_cfg.get("apt", {})
        packages = common + pm.get("extra", [])
        if flags["gui"]:
            packages += pm.get("gui", [])
        apt_install(packages, dry_run)

    elif os_id in ("almalinux", "rocky", "centos", "rhel"):
        pm = sys_cfg.get("dnf", {})
        packages = common + pm.get("extra", [])
        if flags["gui"]:
            packages += pm.get("gui", [])
        # EPEL is required for several packages (bat, stow) on RHEL-family
        run(_elevate(["dnf", "install", "-y", "epel-release"]), dry_run)
        dnf_install(packages, dry_run)

    else:
        print(f"  No system package rule for OS '{os_id}'. Skipping.")


def install_brew_build_deps(manifest: dict, os_id: str, dry_run: bool) -> None:
    deps = manifest.get("brew_build_deps", {})

    if os_id in ("debian", "ubuntu"):
        apt_install(deps.get("apt", []), dry_run)

    elif os_id in ("almalinux", "rocky", "centos", "rhel"):
        if group := deps.get("dnf_group"):
            dnf_groupinstall(group, dry_run)

    else:
        print(f"  No brew-build-dep rule for OS '{os_id}'. Skipping.")


def install_brew(manifest: dict, flags: dict[str, bool], dry_run: bool) -> None:
    formulae: list[str] = list(manifest.get("brew", {}).get("formulae", []))
    if flags["fpga"]:
        formulae += manifest.get("features", {}).get("fpga", {}).get("brew", [])
    brew_install(formulae, dry_run)


# ── Entry point ───────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(description="Install packages from manifest.toml")
    parser.add_argument("-n", "--dry-run", action="store_true",
                        help="Print commands without executing them")
    parser.add_argument("--group",
                        choices=["system", "brew-build-deps", "brew", "all"],
                        default="all",
                        help="Package group to install (default: all)")
    args = parser.parse_args()

    with MANIFEST.open("rb") as f:
        manifest = tomllib.load(f)

    os_id = detect_os()
    flags = load_flags()

    label = "DRY RUN — " if args.dry_run else ""
    print(f"{label}OS={os_id}  GUI={flags['gui']}  FPGA={flags['fpga']}\n")

    if args.group in ("system", "all"):
        print("[system packages]")
        install_system(manifest, os_id, flags, args.dry_run)
        print()

    if args.group in ("brew-build-deps", "all"):
        print("[brew build deps]")
        install_brew_build_deps(manifest, os_id, args.dry_run)
        print()

    if args.group in ("brew", "all"):
        print("[brew formulae]")
        install_brew(manifest, flags, args.dry_run)
        print()


if __name__ == "__main__":
    main()
