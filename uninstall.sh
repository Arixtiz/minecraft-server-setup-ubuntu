#!/bin/bash

echo "⚠️  Desinstalando Minecraft Server..."

systemctl stop minecraft || true
systemctl disable minecraft || true
rm -f /etc/systemd/system/minecraft.service
systemctl daemon-reload

userdel -r minecraft || true
rm -rf /opt/minecraft

echo "🧹 Desinstalación completa"