#!/usr/bin/env bash

set -Eeuo pipefail

LOCALE="pt_BR.UTF-8"
TIMEZONE="America/Sao_Paulo"

echo "Configurando locale..."

if ! grep -q "^${LOCALE} UTF-8" /etc/locale.gen; then
    sed -i "s/^# *${LOCALE} UTF-8/${LOCALE} UTF-8/" /etc/locale.gen
fi

locale-gen "${LOCALE}"

update-locale \
    LANG="${LOCALE}" \
    LANGUAGE="pt_BR:pt:en" \
    LC_ALL="${LOCALE}"

cat >/etc/default/locale <<EOF
LANG=${LOCALE}
LANGUAGE=pt_BR:pt:en
LC_ALL=${LOCALE}
EOF

echo
echo "Configurando timezone..."

timedatectl set-timezone "${TIMEZONE}"

echo
echo "Locale atual:"
locale

echo
echo "Timezone atual:"
timedatectl status | grep "Time zone"

echo
echo "Locale configurado com sucesso."