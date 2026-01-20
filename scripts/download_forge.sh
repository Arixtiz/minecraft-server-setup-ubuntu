#!/bin/bash
set -e

FORGE_META="https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json"
FORGE_MAVEN="https://maven.minecraftforge.net/net/minecraftforge/forge"
SERVER_DIR="/opt/minecraft/server"

mkdir -p "$SERVER_DIR"
cd "$SERVER_DIR"

echo "🔎 Obteniendo versiones de Minecraft disponibles con soporte Forge..."
echo

# 1️⃣ Obtener versiones de Minecraft desde promos (recommended + latest)
mapfile -t MC_VERSIONS < <(
  curl -s "$FORGE_META" |
  grep -oP '"[0-9]+\.[0-9]+(\.[0-9]+)?-(recommended|latest)"' |
  sed 's/"//g' |
  cut -d- -f1 |
  sort -Vr |
  uniq
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

echo
echo "✅ Minecraft seleccionado: $MC_VERSION"
echo

# 2️⃣ Elegir tipo de Forge
echo "🧱 Tipo de Forge:"
echo " [1] Recommended (estable)"
echo " [2] Latest (más reciente)"
echo
read -rp "👉 Selecciona el tipo de Forge [1/2]: " FORGE_TYPE_INPUT

case "$FORGE_TYPE_INPUT" in
  1) FORGE_TYPE="recommended" ;;
  2) FORGE_TYPE="latest" ;;
  *)
    echo "❌ Opción inválida"
    exit 1
    ;;
esac

echo
echo "🔎 Resolviendo versión Forge ($FORGE_TYPE)..."

FORGE_VERSION=$(curl -s "$FORGE_META" |
  grep -oP "\"${MC_VERSION}-${FORGE_TYPE}\":\s*\"[^\"]+\"" |
  sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$FORGE_VERSION" ]; then
  echo "❌ Forge no disponible para Minecraft $MC_VERSION ($FORGE_TYPE)"
  exit 1
fi

echo "✅ Forge seleccionado: $FORGE_VERSION"
echo

# 3️⃣ Descargar e instalar Forge
INSTALLER="forge-${MC_VERSION}-${FORGE_VERSION}-installer.jar"
INSTALLER_URL="$FORGE_MAVEN/${MC_VERSION}-${FORGE_VERSION}/${INSTALLER}"

echo "⬇️ Descargando Forge Installer..."
wget -q --show-progress -O "$INSTALLER" "$INSTALLER_URL"

echo
echo "⚙️ Instalando Forge Server..."
java -jar "$INSTALLER" --installServer

echo
echo "🧹 Limpiando archivos temporales..."
rm -f "$INSTALLER"

# Ajustar permisos si existe el usuario minecraft
if id minecraft &>/dev/null; then
  chown -R minecraft:minecraft /opt/minecraft
fi

echo
echo "🎉 Forge instalado correctamente"
echo "📁 Directorio del servidor: $SERVER_DIR"
echo
echo "👉 Próximo paso: aceptar EULA y configurar server.properties"