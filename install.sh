#!/bin/bash
set -e

echo "🟩 Minecraft Forge Server Setup for Ubuntu"

if [ "$EUID" -ne 0 ]; then
  echo "❌ Ejecuta con sudo"
  exit 1
fi

source .env.example
[ -f .env ] && source .env

apt update && apt install -y curl wget unzip ufw screen

bash scripts/install_java.sh
bash scripts/create_user.sh
bash scripts/download_forge.sh
bash scripts/generate_server_properties.sh
bash scripts/generate_systemd_service.sh
bash scripts/first_run.sh
bash scripts/setup_firewall.sh

echo "⚙️ Instalando systemd service..."
cp systemd/minecraft-forge.service /etc/systemd/system/minecraft-forge.service
systemctl daemon-reload
systemctl enable minecraft-forge

echo "✅ Forge instalado correctamente"
echo "👉 Inicia con: sudo systemctl start minecraft-forge"