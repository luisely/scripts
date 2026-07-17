#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${ROOT_DIR}/configs"

REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || whoami)}"
USER_HOME="$(eval echo "~${REAL_USER}")"

OH_MY_ZSH="${USER_HOME}/.oh-my-zsh"
ZSH_CUSTOM="${OH_MY_ZSH}/custom"

echo "Configurando ZSH para: ${REAL_USER}"

###############################################################################
# Instala ZSH
###############################################################################

if ! command -v zsh >/dev/null 2>&1; then
    apt update
    apt install -y zsh
fi

###############################################################################
# Instala Oh My Zsh
###############################################################################

if [[ ! -d "${OH_MY_ZSH}" ]]; then

    echo "Instalando Oh My Zsh..."

    sudo -u "${REAL_USER}" env \
        RUNZSH=no \
        CHSH=no \
        KEEP_ZSHRC=yes \
        sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

else

    echo "Oh My Zsh já instalado."

fi

###############################################################################
# Powerlevel10k
###############################################################################

if [[ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]]; then

    sudo -u "${REAL_USER}" git clone --depth=1 \
        https://github.com/romkatv/powerlevel10k.git \
        "${ZSH_CUSTOM}/themes/powerlevel10k"

fi

###############################################################################
# Plugins
###############################################################################

install_plugin() {

    local repo="$1"
    local folder="$2"

    if [[ ! -d "${folder}" ]]; then
        sudo -u "${REAL_USER}" git clone --depth=1 "$repo" "$folder"
    fi

}

install_plugin \
https://github.com/zsh-users/zsh-autosuggestions \
"${ZSH_CUSTOM}/plugins/zsh-autosuggestions"

install_plugin \
https://github.com/zsh-users/zsh-syntax-highlighting \
"${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"

install_plugin \
https://github.com/zsh-users/zsh-completions \
"${ZSH_CUSTOM}/plugins/zsh-completions"

###############################################################################
# FZF
###############################################################################

if [[ ! -d "${USER_HOME}/.fzf" ]]; then

    sudo -u "${REAL_USER}" git clone --depth=1 \
        https://github.com/junegunn/fzf.git \
        "${USER_HOME}/.fzf"

    sudo -u "${REAL_USER}" \
        "${USER_HOME}/.fzf/install" \
        --all

fi

###############################################################################
# Copia .zshrc
###############################################################################

if [[ -f "${CONFIG_DIR}/zshrc" ]]; then

    cp "${CONFIG_DIR}/zshrc" "${USER_HOME}/.zshrc"
    chown "${REAL_USER}:${REAL_USER}" "${USER_HOME}/.zshrc"

fi

###############################################################################
# Copia configuração Powerlevel10k
###############################################################################

if [[ -f "${CONFIG_DIR}/p10k.zsh" ]]; then

    cp "${CONFIG_DIR}/p10k.zsh" "${USER_HOME}/.p10k.zsh"
    chown "${REAL_USER}:${REAL_USER}" "${USER_HOME}/.p10k.zsh"

fi

###############################################################################
# Shell padrão
###############################################################################

CURRENT_SHELL="$(getent passwd "${REAL_USER}" | cut -d: -f7)"

if [[ "${CURRENT_SHELL}" != "$(which zsh)" ]]; then
    chsh -s "$(which zsh)" "${REAL_USER}"
fi

###############################################################################
# Permissões
###############################################################################

chown -R "${REAL_USER}:${REAL_USER}" "${OH_MY_ZSH}"

echo
echo "ZSH configurado com sucesso."