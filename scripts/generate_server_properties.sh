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

echo
echo "📝 Generando server.properties..."
echo

cat > "$PROPS_FILE" <<EOF
# ===============================
# Minecraft Server Configuration
# Generated automatically
# ===============================

# General
motd=Minecraft Server on Ubuntu
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

echo "✅ server.properties creado correctamente"
echo "📍 Ubicación: $PROPS_FILE"