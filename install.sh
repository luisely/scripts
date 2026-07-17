#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${ROOT_DIR}/utils.sh"

clear

title "Debian Bootstrap"

require_root

check_debian

echo

log "Atualizando lista de pacotes..."
apt update

echo

run_step "Instalando pacotes" \
    bash "${ROOT_DIR}/packages.sh"

run_step "Configurando locale e timezone" \
    bash "${ROOT_DIR}/locale.sh"

run_step "Configurando ZSH" \
    bash "${ROOT_DIR}/zsh.sh"

run_step "Configurando aliases" \
    bash "${ROOT_DIR}/aliases.sh"

run_step "Configurando MOTD" \
    bash "${ROOT_DIR}/motd.sh"

run_step "Limpeza do sistema" \
    bash "${ROOT_DIR}/cleanup.sh"

echo
success "Bootstrap concluído com sucesso!"
echo

echo "Próximos passos:"
echo
echo "1) Feche e abra novamente o terminal"
echo "2) Execute:"
echo
echo "   zsh"
echo
echo "Caso não exista um configs/p10k.zsh execute:"
echo
echo "   p10k configure"
echo