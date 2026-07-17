#!/usr/bin/env bash

set -Eeuo pipefail

#########################################
# Cores
#########################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
RESET='\033[0m'

#########################################
# Mensagens
#########################################

title() {
    echo -e "${CYAN}${BOLD}"
    echo "============================================================"
    echo " $1"
    echo "============================================================"
    echo -e "${RESET}"
}

log() {
    echo -e "${BLUE}==>${RESET} $1"
}

success() {
    echo -e "${GREEN}✔${RESET} $1"
}

warn() {
    echo -e "${YELLOW}⚠${RESET} $1"
}

error() {
    echo -e "${RED}✘${RESET} $1"
}

#########################################
# Validações
#########################################

require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        error "Execute como root."
        exit 1
    fi
}

check_debian() {

    if [[ ! -f /etc/os-release ]]; then
        error "Sistema operacional não identificado."
        exit 1
    fi

    source /etc/os-release

    if [[ "$ID" != "debian" ]]; then
        error "Este script suporta apenas Debian."
        exit 1
    fi

    case "$VERSION_ID" in
        12|13)
            success "Debian ${VERSION_ID} detectado."
            ;;
        *)
            warn "Versão Debian ${VERSION_ID} não homologada."
            ;;
    esac
}

#########################################
# Execução de etapas
#########################################

run_step() {

    local description="$1"
    shift

    echo
    log "$description"

    if "$@"; then
        success "$description concluído."
    else
        error "$description falhou."
        exit 1
    fi
}

#########################################
# Instala pacote apenas se necessário
#########################################

install_if_missing() {

    local pkg="$1"

    if dpkg -s "$pkg" &>/dev/null; then
        log "$pkg já instalado."
    else
        apt install -y "$pkg"
    fi
}

#########################################
# Clonar repositório apenas se necessário
#########################################

clone_if_missing() {

    local repo="$1"
    local destination="$2"

    if [[ -d "$destination" ]]; then
        log "$(basename "$destination") já existe."
    else
        git clone --depth=1 "$repo" "$destination"
    fi
}

#########################################
# Adiciona linha ao arquivo se inexistente
#########################################

append_if_missing() {

    local line="$1"
    local file="$2"

    touch "$file"

    if ! grep -Fxq "$line" "$file"; then
        echo "$line" >> "$file"
    fi
}

#########################################
# Backup
#########################################

backup_file() {

    local file="$1"

    if [[ -f "$file" ]]; then
        cp "$file" "${file}.bak.$(date +%Y%m%d%H%M%S)"
    fi
}

#########################################
# Detecta arquitetura
#########################################

architecture() {
    dpkg --print-architecture
}

#########################################
# Detecta IP principal
#########################################

get_ip() {

    hostname -I 2>/dev/null | awk '{print $1}'
}

#########################################
# Detecta hostname
#########################################

get_hostname() {

    hostname
}

#########################################
# Detecta usuário padrão
#########################################

get_real_user() {

    if [[ -n "${SUDO_USER:-}" ]]; then
        echo "$SUDO_USER"
    else
        logname 2>/dev/null || whoami
    fi
}

#########################################
# Executa comando como usuário real
#########################################

run_as_user() {

    local user

    user="$(get_real_user)"

    if [[ "$user" == "root" ]]; then
        "$@"
    else
        sudo -u "$user" "$@"
    fi
}

#########################################
# Banner
#########################################

print_line() {
    printf '%*s\n' "${COLUMNS:-60}" '' | tr ' ' '='
}