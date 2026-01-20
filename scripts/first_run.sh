#!/bin/bash

SERVER_DIR="/opt/minecraft/server"

echo "📄 Aceptando EULA..."
cp config/eula.txt $SERVER_DIR/eula.txt

echo "📁 Copiando server.properties..."
cp config/server.properties $SERVER_DIR/

echo "📦 Preparando carpeta mods..."
mkdir -p $SERVER_DIR/mods
cp mods/* $SERVER_DIR/mods/ 2>/dev/null || true

chown -R minecraft:minecraft /opt/minecraft