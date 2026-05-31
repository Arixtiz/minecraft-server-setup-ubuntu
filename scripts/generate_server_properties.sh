#!/bin/bash
set -e

SERVER_DIR="/opt/minecraft/server"
PROPS_FILE="$SERVER_DIR/server.properties"

echo "⚙️ Configuración inicial del servidor Minecraft"
echo

# Preguntar número de jugadores
read -rp "👥 ¿Cuántos jugadores máximos tendrá el servidor? [10]: " MAX_PLAYERS
MAX_PLAYERS=${MAX_PLAYERS:-10}

# Validación básica
if ! [[ "$MAX_PLAYERS" =~ ^[0-9]+$ ]]; then
  echo "❌ Número de jugadores inválido"
  exit 1
fi

# Preguntar nombre del mundo
read -rp "🌍 Nombre del mundo [world]: " LEVEL_NAME
LEVEL_NAME=${LEVEL_NAME:-world}

# Preguntar MOTD
echo
echo "💬 El MOTD es el mensaje que aparece en la lista de servidores de Minecraft."
read -rp "💬 MOTD del servidor [Minecraft Server on Ubuntu]: " MOTD
MOTD=${MOTD:-Minecraft Server on Ubuntu}

# Preguntar imagen del servidor
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ICON="$SCRIPT_DIR/../assets/server-icon.png"
echo
echo "🖼️  La imagen del servidor debe ser un PNG de exactamente 64x64 píxeles."
echo "   (Deja en blanco para usar la imagen por defecto)"
read -rp "🖼️  Ruta a tu server-icon.png [por defecto]: " CUSTOM_ICON

if [ -n "$CUSTOM_ICON" ]; then
  if [ ! -f "$CUSTOM_ICON" ]; then
    echo "⚠️  Archivo no encontrado: $CUSTOM_ICON — usando imagen por defecto."
    ICON_SRC="$DEFAULT_ICON"
  else
    ICON_SRC="$CUSTOM_ICON"
  fi
else
  ICON_SRC="$DEFAULT_ICON"
fi

echo
echo "📝 Generando server.properties..."
echo

cat > "$PROPS_FILE" <<EOF
# ===============================
# Minecraft Server Configuration
# Generated automatically
# ===============================

# General
motd=$MOTD
max-players=$MAX_PLAYERS
online-mode=false

# Gameplay
difficulty=normal
pvp=true
hardcore=false
enable-command-block=false

# Mundo
level-name=$LEVEL_NAME
level-type=default
generate-structures=true

# Rendimiento
view-distance=10
simulation-distance=6
network-compression-threshold=256
max-tick-time=60000

# Spawn
spawn-protection=16
spawn-animals=true
spawn-monsters=true
spawn-npcs=true

# Red
allow-nether=true
enable-query=false
enable-rcon=false
server-port=25565
EOF

chown minecraft:minecraft "$PROPS_FILE"

# Copiar imagen del servidor
ICON_DEST="$SERVER_DIR/server-icon.png"
if [ -f "$ICON_SRC" ]; then
  cp "$ICON_SRC" "$ICON_DEST"
  chown minecraft:minecraft "$ICON_DEST"
  echo "🖼️  server-icon.png copiado correctamente"
else
  echo "⚠️  No se encontró ninguna imagen de servidor (omitiendo)"
fi

echo "✅ server.properties creado correctamente"
echo "📍 Ubicación: $PROPS_FILE"
echo "🖼️  Ícono:      $ICON_DEST"