#!/usr/bin/env bash

set -Eeuo pipefail

MOTD_FILE="/etc/update-motd.d/99-bootstrap"

echo "Configurando MOTD..."

cat > "${MOTD_FILE}" <<'EOF'
#!/usr/bin/env bash

HOSTNAME=$(hostname)

IP=$(hostname -I | awk '{print $1}')

KERNEL=$(uname -r)

UPTIME=$(uptime -p | sed 's/up //')

CPU=$(nproc)

MEM_TOTAL=$(free -h | awk '/Mem:/ {print $2}')

MEM_USED=$(free -h | awk '/Mem:/ {print $3}')

DISK=$(df -h / | awk 'NR==2 {print $3 " / " $2}')

LOAD=$(awk '{print $1}' /proc/loadavg)


echo
echo "============================================================"
echo " Debian Bootstrap"
echo "============================================================"
echo
echo " Host........: ${HOSTNAME}"
echo " IP..........: ${IP}"
echo " Kernel......: ${KERNEL}"
echo " Uptime......: ${UPTIME}"
echo " CPU.........: ${CPU} vCPU"
echo " Memory......: ${MEM_USED} / ${MEM_TOTAL}"
echo " Disk........: ${DISK}"
echo " Load........: ${LOAD}"
echo
echo "============================================================"
echo

if command -v fastfetch >/dev/null 2>&1; then
    fastfetch --logo none
fi
EOF


chmod +x "${MOTD_FILE}"


###############################################################################
# Remove MOTDs padrão Debian
###############################################################################

if [[ -d /etc/update-motd.d ]]; then

    chmod -x /etc/update-motd.d/* 2>/dev/null || true

    chmod +x "${MOTD_FILE}"

fi


###############################################################################
# Configura SSH
###############################################################################

SSH_CONFIG="/etc/ssh/sshd_config"

echo "Configurando SSH..."

# MOTD
if grep -q "^PrintMotd" "${SSH_CONFIG}"; then
    sed -i 's/^PrintMotd.*/PrintMotd yes/' "${SSH_CONFIG}"
else
    echo "PrintMotd yes" >> "${SSH_CONFIG}"
fi


# Permitir login SSH como root
if grep -q "^#PermitRootLogin" "${SSH_CONFIG}"; then
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' "${SSH_CONFIG}"
elif grep -q "^PermitRootLogin" "${SSH_CONFIG}"; then
    sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' "${SSH_CONFIG}"
else
    echo "PermitRootLogin yes" >> "${SSH_CONFIG}"
fi


# Permitir autenticação por senha
if grep -q "^#PasswordAuthentication" "${SSH_CONFIG}"; then
    sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' "${SSH_CONFIG}"
elif grep -q "^PasswordAuthentication" "${SSH_CONFIG}"; then
    sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' "${SSH_CONFIG}"
else
    echo "PasswordAuthentication yes" >> "${SSH_CONFIG}"
fi


systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null || true


echo
echo "SSH configurado:"
echo "- Login root habilitado"
echo "- Login por senha habilitado"
echo "- MOTD habilitado"