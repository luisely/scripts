#!/usr/bin/env bash

set -Eeuo pipefail

PACKAGES=(
    # Shell
    zsh
    tmux

    # Utilitários
    sudo
    curl
    wget
    git
    nano
    vim
    less
    tree
    rsync
    unzip
    zip
    tar
    file

    # Monitoramento
    htop
    btop
    iftop
    iotop
    ncdu
    lsof

    # Rede
    dnsutils
    net-tools
    iputils-ping
    traceroute

    # Ferramentas CLI
    jq
    ripgrep
    fd-find
    fzf
    bat
    eza

    # Sistema
    ca-certificates
    gnupg
    locales
    tzdata

    # Virtualização
    qemu-guest-agent

    # Build
    build-essential
    pkg-config

    # Extras
    bash-completion
)

echo "Atualizando repositórios..."
apt update

echo "Atualizando sistema..."
apt full-upgrade -y

echo "Instalando pacotes..."

for package in "${PACKAGES[@]}"; do

    if dpkg -s "$package" &>/dev/null; then
        echo "✔ $package já instalado."
    else
        echo "➜ Instalando $package..."
        apt install -y "$package"
    fi

done

echo

echo "Habilitando qemu-guest-agent..."

systemctl enable qemu-guest-agent
systemctl restart qemu-guest-agent

echo

echo "Instalando zoxide..."

if ! command -v zoxide &>/dev/null; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
else
    echo "✔ zoxide já instalado."
fi

echo

echo "Instalando fastfetch..."

if ! command -v fastfetch &>/dev/null; then

    if apt-cache show fastfetch &>/dev/null; then
        apt install -y fastfetch
    else
        echo "⚠ fastfetch não disponível nos repositórios."
    fi

else
    echo "✔ fastfetch já instalado."
fi

echo

echo "Removendo pacotes obsoletos..."

apt autoremove -y

echo

echo "Pacotes instalados com sucesso."