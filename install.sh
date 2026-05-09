#!/bin/bash
set -e

echo "🟩 Minecraft Server Setup for Ubuntu"
echo "======================================"
echo

if [ "$EUID" -ne 0 ]; then
  echo "❌ Ejecuta este script con sudo"
  exit 1
fi

# Cargar variables de entorno
source .env.example
[ -f .env ] && source .env

echo "📦 Actualizando sistema e instalando dependencias..."
apt update && apt install -y curl wget unzip ufw screen jq
echo

# ==============================
# Selección de tipo de servidor
# ==============================
echo "🎮 Selecciona el tipo de servidor:"
echo "  [1] Vanilla   — Servidor oficial de Mojang"
echo "  [2] PaperMC   — Alto rendimiento + plugins Bukkit/Spigot"
echo "  [3] Fabric    — Mods modernos, ligero y optimizado ⭐"
echo "  [4] NeoForge  — Fork moderno de Forge (1.20.2+) ⭐"
echo "  [5] Forge     — Mods tradicionales (mayor compatibilidad)"
echo

if [ -n "$SERVER_TYPE" ]; then
  echo "📄 Tipo detectado desde .env: $SERVER_TYPE"
else
  read -rp "👉 Selecciona una opción [1]: " _TYPE_INPUT
  case "${_TYPE_INPUT:-1}" in
    1) SERVER_TYPE="vanilla" ;;
    2) SERVER_TYPE="papermc" ;;
    3) SERVER_TYPE="fabric" ;;
    4) SERVER_TYPE="neoforge" ;;
    5) SERVER_TYPE="forge" ;;
    *)
      echo "❌ Opción inválida"
      exit 1
      ;;
  esac
fi

export SERVER_TYPE
echo "✅ Tipo seleccionado: $SERVER_TYPE"
echo

# ==============================
# Secuencia de instalación
# ==============================
bash scripts/download_server.sh
bash scripts/install_java.sh
bash scripts/create_user.sh
bash scripts/generate_server_properties.sh
bash scripts/generate_systemd_service.sh
bash scripts/first_run.sh
bash scripts/setup_firewall.sh

echo
echo "⚙️ Habilitando servicio systemd..."
systemctl daemon-reload
systemctl enable minecraft

echo
echo "✅ ¡Servidor Minecraft ($SERVER_TYPE) instalado correctamente!"
echo "👉 Inicia con:  sudo systemctl start minecraft"
echo "👉 Ver logs:    journalctl -u minecraft -f"
echo "👉 Estado:      sudo systemctl status minecraft"