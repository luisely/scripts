#!/usr/bin/env bash

set -Eeuo pipefail

REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || whoami)}"
USER_HOME="$(eval echo "~${REAL_USER}")"

ZSHRC="${USER_HOME}/.zshrc"

touch "${ZSHRC}"

append_alias() {

    local alias_line="$1"

    if ! grep -Fqx "$alias_line" "${ZSHRC}"; then
        echo "$alias_line" >> "${ZSHRC}"
    fi
}

echo ""
echo "# ====================================================" >> "${ZSHRC}"
echo "# Aliases personalizados" >> "${ZSHRC}"
echo "# ====================================================" >> "${ZSHRC}"
echo "" >> "${ZSHRC}"

###############################################################################
# Navegação
###############################################################################

append_alias "alias ..='cd ..'"
append_alias "alias ...='cd ../..'"
append_alias "alias ....='cd ../../..'"
append_alias "alias c='clear'"

###############################################################################
# EZA
###############################################################################

append_alias "alias ls='eza --icons'"
append_alias "alias ll='eza -lah --icons'"
append_alias "alias la='eza -a --icons'"
append_alias "alias lt='eza --tree --level=2 --icons'"

###############################################################################
# BAT
###############################################################################

if command -v batcat >/dev/null 2>&1; then
    append_alias "alias cat='batcat'"
elif command -v bat >/dev/null 2>&1; then
    append_alias "alias cat='bat'"
fi

###############################################################################
# Sistema
###############################################################################

append_alias "alias df='df -h'"
append_alias "alias du='du -sh'"
append_alias "alias free='free -h'"
append_alias "alias ports='ss -tulpn'"
append_alias "alias psmem='ps aux --sort=-%mem | head'"
append_alias "alias pscpu='ps aux --sort=-%cpu | head'"

###############################################################################
# Rede
###############################################################################

append_alias "alias myip='curl -4 ifconfig.me && echo'"
append_alias "alias weather='curl wttr.in'"

###############################################################################
# APT
###############################################################################

append_alias "alias update='sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean'"
append_alias "alias install='sudo apt install'"
append_alias "alias remove='sudo apt remove'"

###############################################################################
# Docker
###############################################################################

append_alias "alias d='docker'"
append_alias "alias dc='docker compose'"
append_alias "alias dps='docker ps'"
append_alias "alias dpa='docker ps -a'"
append_alias "alias di='docker images'"

###############################################################################
# Git
###############################################################################

append_alias "alias gs='git status'"
append_alias "alias ga='git add .'"
append_alias "alias gc='git commit'"
append_alias "alias gp='git push'"
append_alias "alias gl='git log --oneline --graph --decorate'"

###############################################################################
# Fastfetch
###############################################################################

if command -v fastfetch >/dev/null 2>&1; then
    append_alias "alias ff='fastfetch'"
fi

###############################################################################
# Zoxide
###############################################################################

append_alias 'eval "$(zoxide init zsh)"'

###############################################################################
# FZF
###############################################################################

append_alias '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh'

chown "${REAL_USER}:${REAL_USER}" "${ZSHRC}"

echo "Aliases configurados com sucesso."