#!/bin/sh

set -eu

get_os_info() {
    ID="unknown"
    IS_WSL=false

    if [ -n "${WSL_DISTRO_NAME:-}" ] || [ -f /proc/version ] && grep -qi "microsoft" /proc/version; then
        IS_WSL=true
    fi

    if [ "$(uname -s)" = "Darwin" ]; then
        ID="darwin"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        ID="${ID:-unknown}"
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        ID="${DISTRIB_ID:-unknown}" | tr '[:upper:]' '[:lower:]'
    elif [ -f /etc/debian_version ]; then
        ID="debian"
    elif [ -f /etc/arch-release ]; then
        ID="arch"
    elif [ -f /etc/redhat-release ]; then
        if grep -qi "red hat" /etc/redhat-release; then
            ID="rhel"
        elif grep -qi "centos" /etc/redhat-release; then
            ID="centos"
        elif grep -qi "fedora" /etc/redhat-release; then
            ID="fedora"
        else
            ID="redhat"
        fi
    elif [ -f /etc/alpine-release ]; then
        ID="alpine"
    else
        ID=$(uname -s | tr '[:upper:]' '[:lower:]')
    fi

    # 输出结果
    printf "ID=%s\n" "$ID"
    printf "IS_WSL=%s\n" "$IS_WSL"
}

eval "$(get_os_info)"

init_macos() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    brew install fish git wget bat 
    echo "/opt/homebrew/bin/fish" | sudo tee -a /etc/shells
    chsh -s /opt/homebrew/bin/fish
}

init_redhat() {
    sudo passwd $USER
    sudo dnf install -y fish git binutils curl wget bat fakeroot
    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply waterlens
    chsh -s /usr/bin/fish
}

setup_paru() {
    mkdir -p paru
    cd paru
    wget -O PKGBUILD "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=paru-bin"
    makepkg -si
    cd ..
    rm -rf paru
}

init_arch() {
    sudo passwd $USER
    sudo pacman -S openssl-1.1 # required on aarch64
    sudo pacman -S fish git binutils curl wget bat fakeroot chezmoi
    chezmoi init --apply waterlens
    chsh -s /usr/bin/fish
}

init_debian() {
    sudo passwd $USER
    sudo apt-get update
    sudo apt-get install -y fish git binutils curl wget fakeroot
    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply waterlens
    chsh -s /usr/bin/fish
}

init_ssh() {
    echo "Do you want to add your SSH public key to the authorized_keys file? (y/n)"
    REPLY=; read REPLY
    case "$REPLY" in
        [Yy]*) 
            mkdir -p ~/.ssh
            curl https://github.com/waterlens.keys >> ~/.ssh/authorized_keys
            chmod 600 ~/.ssh/authorized_keys
            chmod 700 ~/.ssh
            ;;
        *)
            echo "Skipping SSH key addition"
            ;;
    esac
}

case "$ID" in
    "darwin")
        echo "macOS detected"
        init_macos
        ;;
    "arch")
        echo "Arch Linux detected"
        init_arch
        ;;
    "rhel" | "centos" | "fedora")
        echo "RedHat-like OS detected"
        init_redhat
        ;;
    "debian" | "ubuntu")
        echo "Debian-like OS detected"
        init_debian
        ;;
    *)
        echo "Unsupported OS ($ID) detected"
        ;;
esac

init_ssh
