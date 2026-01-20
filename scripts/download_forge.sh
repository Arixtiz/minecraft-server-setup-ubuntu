#!/bin/bash
set -e

FORGE_META="https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json"
FORGE_MAVEN="https://maven.minecraftforge.net/net/minecraftforge/forge"
SERVER_DIR="/opt/minecraft/server"

mkdir -p "$SERVER_DIR"
cd "$SERVER_DIR"

echo "🔎 Obteniendo versiones de Minecraft disponibles en Forge..."
echo

# 1️⃣ Obtener versiones de Minecraft desde JSON
mapfile -t MC_VERSIONS < <(
  curl -s "$FORGE_META" |
  grep -oP '"[0-9]+\.[0-9]+(\.[0-9]+)?-recommended"' |
  sed 's/"//g' |
  sed 's/-recommended//g' |
  sort -Vr
)

if [ "${#MC_VERSIONS[@]}" -eq 0 ]; then
  echo "❌ No se pudieron obtener versiones de Minecraft desde Forge"
  exit 1
fi

echo "🎮 Versiones de Minecraft disponibles:"
for i in "${!MC_VERSIONS[@]}"; do
  printf " [%d] %s\n" "$i" "${MC_VERSIONS[$i]}"
done

echo
read -rp "👉 Selecciona la versión de Minecraft: " MC_INDEX
MC_VERSION="${MC_VERSIONS[$MC_INDEX]}"

if [ -z "$MC_VERSION" ]; then
  echo "❌ Selección inválida"
  exit 1
fi

echo "✅ Minecraft seleccionado: $MC_VERSION"
echo

# 2️⃣ Obtener versiones Forge para esa versión
echo "🔎 Buscando versiones Forge para Minecraft $MC_VERSION..."
echo

mapfile -t FORGE_VERSIONS < <(
  curl -s "$FORGE_MAVEN" |
  grep -oP "(?<=href=\")${MC_VERSION}-[0-9]+\.[0-9]+\.[0-9]+(?=/\")" |
  sed "s/^${MC_VERSION}-//" |
  sort -Vr
)

if [ "${#FORGE_VERSIONS[@]}" -eq 0 ]; then
  echo "❌ No se encontraron versiones Forge para $MC_VERSION"
  exit 1
fi

echo "🧱 Versiones Forge disponibles:"
for i in "${!FORGE_VERSIONS[@]}"; do
  printf " [%d] %s\n" "$i" "${FORGE_VERSIONS[$i]}"
done

echo
read -rp "👉 Selecciona la versión de Forge: " FORGE_INDEX
FORGE_VERSION="${FORGE_VERSIONS[$FORGE_INDEX]}"

if [ -z "$FORGE_VERSION" ]; then
  echo "❌ Selección inválida"
  exit 1
fi

echo "✅ Forge seleccionado: $FORGE_VERSION"
echo

# 3️⃣ Descargar e instalar
INSTALLER="forge-${MC_VERSION}-${FORGE_VERSION}-installer.jar"
INSTALLER_URL="$FORGE_MAVEN/${MC_VERSION}-${FORGE_VERSION}/$INSTALLER"

echo "⬇️ Descargando Forge Installer..."
wget -q --show-progress -O "$INSTALLER" "$INSTALLER_URL"

echo "⚙️ Instalando Forge..."
java -jar "$INSTALLER" --installServer

rm -f "$INSTALLER"
chown -R minecraft:minecraft /opt/minecraft

echo "🎉 Forge instalado correctamente"