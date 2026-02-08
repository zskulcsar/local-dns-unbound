#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: setup-core.sh <docker|podman> <image>

Examples:
  setup-core.sh docker alpine/ansible:latest
  setup-core.sh podman alpine/ansible:2.20.0
USAGE
}

if [ "$#" -ne 2 ]; then
  usage
  exit 1
fi

RUNTIME="$1"
IMAGE="$2"

case "$RUNTIME" in
  docker|podman)
    ;;
  *)
    echo "Error: runtime must be 'docker' or 'podman'" >&2
    usage
    exit 1
    ;;
esac

install_runtime() {
  local runtime="$1"
  local pkg="${runtime}"

  if [ "$runtime" = "docker" ]; then
    pkg="docker.io"
  fi

  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y "$pkg"
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y "$pkg"
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y "$pkg"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm "$pkg"
  elif command -v zypper >/dev/null 2>&1; then
    sudo zypper install -y "$pkg"
  else
    echo "Error: no supported package manager found to install ${runtime}." >&2
    exit 1
  fi
}

install_ssh_server() {
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y openssh-server
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y openssh-server
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y openssh-server
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm openssh
  elif command -v zypper >/dev/null 2>&1; then
    sudo zypper install -y openssh
  else
    echo "Error: no supported package manager found to install OpenSSH server." >&2
    exit 1
  fi
}

ensure_ssh_service_running() {
  local svc=""

  if command -v systemctl >/dev/null 2>&1; then
    if systemctl list-unit-files 2>/dev/null | grep -q '^ssh\.service'; then
      svc="ssh"
    elif systemctl list-unit-files 2>/dev/null | grep -q '^sshd\.service'; then
      svc="sshd"
    fi

    if [ -n "$svc" ]; then
      sudo systemctl enable --now "${svc}.service"
    else
      echo "Warning: could not detect ssh/sshd systemd service name; skipping service startup." >&2
    fi
  else
    echo "Warning: systemctl not available; start SSH server manually if needed." >&2
  fi
}

if ! command -v "$RUNTIME" >/dev/null 2>&1; then
  echo "${RUNTIME} is not installed; installing..."
  install_runtime "$RUNTIME"
fi

if ! command -v sshd >/dev/null 2>&1; then
  echo "OpenSSH server is not installed; installing..."
  install_ssh_server
fi

ensure_ssh_service_running

PULL_IMAGE="$IMAGE"
if [ "$RUNTIME" = "podman" ]; then
  first_part="${IMAGE%%/*}"
  if [[ "$first_part" != *.* && "$first_part" != *:* && "$first_part" != "localhost" ]]; then
    PULL_IMAGE="docker.io/${IMAGE}"
  fi
fi

echo "Pulling ${PULL_IMAGE} with ${RUNTIME}..."
"$RUNTIME" pull "$PULL_IMAGE"

echo "Done."
