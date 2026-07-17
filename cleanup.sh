#!/usr/bin/env bash

set -Eeuo pipefail

echo "Removendo dependências não utilizadas..."
apt autoremove -y

echo
echo "Limpando cache do APT..."
apt autoclean -y

echo
echo "Removendo pacotes antigos do cache..."
apt clean

echo
echo "Removendo listas antigas de pacotes..."
rm -rf /var/lib/apt/lists/*

echo
echo "Atualizando banco do locate..."

if command -v updatedb >/dev/null 2>&1; then
    updatedb
fi

echo
echo "Sincronizando dados em disco..."
sync

echo
echo "Limpeza concluída."