#!/bin/bash

echo "⚠️ Desinstalando Minecraft Forge Server..."

systemctl stop minecraft-forge || true
systemctl disable minecraft-forge || true
rm -f /etc/systemd/system/minecraft-forge.service
systemctl daemon-reload

userdel -r minecraft || true
rm -rf /opt/minecraft

echo "🧹 Desinstalación completa"