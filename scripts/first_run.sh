#!/bin/bash

SERVER_DIR="/opt/minecraft/server"
META_FILE="/opt/minecraft/.server-meta"

# Cargar tipo de servidor
if [ -f "$META_FILE" ]; then
  source "$META_FILE"
fi

echo "📄 Aceptando EULA de Mojang..."
cp config/eula.txt "$SERVER_DIR/eula.txt"

echo "📁 Aplicando configuración inicial..."

# Copiar server.properties si existe en config/
if [ -f "config/server.properties" ]; then
  cp config/server.properties "$SERVER_DIR/"
fi

# Copiar mods solo para Fabric y Forge (Vanilla/PaperMC no los usan)
case "$SERVER_TYPE" in
  fabric | forge)
    echo "📦 Preparando carpeta de mods para $SERVER_TYPE..."
    mkdir -p "$SERVER_DIR/mods"
    # Copiar mods si hay alguno (excluir .gitkeep)
    find mods/ -type f ! -name '.gitkeep' -exec cp {} "$SERVER_DIR/mods/" \; 2>/dev/null || true
    echo "   → Carpeta mods lista: $SERVER_DIR/mods/"
    ;;
  vanilla | papermc)
    echo "ℹ️  Tipo $SERVER_TYPE no usa mods, omitiendo carpeta mods/"
    ;;
esac

echo "🔒 Ajustando permisos..."
chown -R minecraft:minecraft /opt/minecraft

echo "✅ Configuración inicial completada"