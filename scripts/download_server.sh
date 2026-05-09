#!/bin/bash
set -e

SERVER_DIR="/opt/minecraft/server"
META_FILE="/opt/minecraft/.server-meta"
MOJANG_MANIFEST="https://launchermeta.mojang.com/mc/game/version_manifest_v2.json"

mkdir -p "$SERVER_DIR"
cd "$SERVER_DIR"

echo "📥 Configurando servidor tipo: ${SERVER_TYPE:-sin definir}"
echo

# ==============================
# Helper: guardar metadata
# ==============================
save_meta() {
  mkdir -p /opt/minecraft
  cat > "$META_FILE" <<EOF
MC_VERSION=$MC_VERSION
SERVER_TYPE=$SERVER_TYPE
EOF
  echo "💾 Metadata guardada en $META_FILE"
}

# ==============================
# Helper: seleccionar versión de MC (Mojang)
# ==============================
select_mc_version_mojang() {
  if [ -n "$MC_VERSION" ]; then
    echo "📄 Versión desde entorno: $MC_VERSION"
    return
  fi

  echo "🔎 Obteniendo versiones de Minecraft (releases)..."
  mapfile -t MC_VERSIONS < <(
    curl -s "$MOJANG_MANIFEST" | jq -r '.versions[] | select(.type == "release") | .id' | head -20
  )

  if [ "${#MC_VERSIONS[@]}" -eq 0 ]; then
    echo "❌ No se pudieron obtener versiones desde Mojang"
    exit 1
  fi

  echo "🎮 Versiones disponibles (últimas releases):"
  for i in "${!MC_VERSIONS[@]}"; do
    printf "  [%2d] %s\n" "$i" "${MC_VERSIONS[$i]}"
  done
  echo

  read -rp "👉 Selecciona la versión [0 = más reciente]: " MC_IDX
  MC_VERSION="${MC_VERSIONS[${MC_IDX:-0}]}"

  if [ -z "$MC_VERSION" ]; then
    echo "❌ Selección inválida"
    exit 1
  fi

  echo "✅ Minecraft seleccionado: $MC_VERSION"
  export MC_VERSION
}

# ==============================
# VANILLA
# ==============================
download_vanilla() {
  echo "🟩 Descargando Vanilla Server..."
  echo

  select_mc_version_mojang

  echo "🔎 Obteniendo URL del servidor desde Mojang..."
  VERSION_URL=$(curl -s "$MOJANG_MANIFEST" \
    | jq -r --arg v "$MC_VERSION" '.versions[] | select(.id == $v) | .url')

  SERVER_JAR_URL=$(curl -s "$VERSION_URL" | jq -r '.downloads.server.url')

  if [ -z "$SERVER_JAR_URL" ] || [ "$SERVER_JAR_URL" = "null" ]; then
    echo "❌ No existe servidor dedicado para Minecraft $MC_VERSION"
    exit 1
  fi

  echo "⬇️  Descargando server.jar..."
  wget -q --show-progress -O "$SERVER_DIR/server.jar" "$SERVER_JAR_URL"

  save_meta
  echo
  echo "✅ Vanilla Server $MC_VERSION descargado correctamente"
}

# ==============================
# PAPERMC
# ==============================
download_papermc() {
  PAPER_API="https://api.papermc.io/v2/projects/paper"

  echo "📄 Descargando PaperMC Server..."
  echo

  if [ -n "$MC_VERSION" ]; then
    echo "📄 Versión desde entorno: $MC_VERSION"
  else
    echo "🔎 Obteniendo versiones de PaperMC disponibles..."
    mapfile -t PAPER_VERSIONS < <(
      curl -s "$PAPER_API" | jq -r '.versions[]' | sort -Vr | head -20
    )

    if [ "${#PAPER_VERSIONS[@]}" -eq 0 ]; then
      echo "❌ No se pudieron obtener versiones de PaperMC"
      exit 1
    fi

    echo "🎮 Versiones disponibles:"
    for i in "${!PAPER_VERSIONS[@]}"; do
      printf "  [%2d] %s\n" "$i" "${PAPER_VERSIONS[$i]}"
    done
    echo

    read -rp "👉 Selecciona la versión [0 = más reciente]: " MC_IDX
    MC_VERSION="${PAPER_VERSIONS[${MC_IDX:-0}]}"

    if [ -z "$MC_VERSION" ]; then
      echo "❌ Selección inválida"
      exit 1
    fi

    export MC_VERSION
  fi

  echo "✅ PaperMC versión: $MC_VERSION"
  echo "🔎 Obteniendo último build..."

  LATEST_BUILD=$(curl -s "$PAPER_API/versions/$MC_VERSION/builds" \
    | jq -r '.builds[-1].build')

  if [ -z "$LATEST_BUILD" ] || [ "$LATEST_BUILD" = "null" ]; then
    echo "❌ No se encontró ningún build para $MC_VERSION"
    exit 1
  fi

  JAR_NAME="paper-${MC_VERSION}-${LATEST_BUILD}.jar"
  DOWNLOAD_URL="$PAPER_API/versions/$MC_VERSION/builds/$LATEST_BUILD/downloads/$JAR_NAME"

  echo "⬇️  Descargando $JAR_NAME (build #$LATEST_BUILD)..."
  wget -q --show-progress -O "$SERVER_DIR/server.jar" "$DOWNLOAD_URL"

  save_meta
  echo
  echo "✅ PaperMC $MC_VERSION (build #$LATEST_BUILD) descargado correctamente"
}

# ==============================
# FABRIC
# ==============================
download_fabric() {
  FABRIC_META="https://meta.fabricmc.net/v2/versions"
  FABRIC_INSTALLER_MAVEN="https://maven.fabricmc.net/net/fabricmc/fabric-installer"

  echo "🧵 Descargando Fabric Server..."
  echo

  select_mc_version_mojang

  echo "🔎 Verificando soporte de Fabric para $MC_VERSION..."
  LOADER_VERSION=$(curl -s "$FABRIC_META/loader/$MC_VERSION" \
    | jq -r '[.[] | select(.loader.stable == true)][0].loader.version // empty')

  if [ -z "$LOADER_VERSION" ] || [ "$LOADER_VERSION" = "null" ]; then
    echo "❌ Fabric no tiene soporte estable para Minecraft $MC_VERSION"
    echo "   Consulta versiones soportadas en: https://fabricmc.net/develop"
    exit 1
  fi

  echo "✅ Fabric Loader: $LOADER_VERSION"

  INSTALLER_VERSION=$(curl -s "$FABRIC_META/installer" \
    | jq -r '[.[] | select(.stable == true)][0].version')

  echo "📦 Fabric Installer: $INSTALLER_VERSION"
  echo

  INSTALLER_JAR="fabric-installer-${INSTALLER_VERSION}.jar"
  INSTALLER_DOWNLOAD="$FABRIC_INSTALLER_MAVEN/$INSTALLER_VERSION/$INSTALLER_JAR"

  echo "⬇️  Descargando Fabric Installer..."
  wget -q --show-progress -O "/tmp/$INSTALLER_JAR" "$INSTALLER_DOWNLOAD"

  echo
  echo "⚙️  Instalando Fabric Server en $SERVER_DIR..."
  java -jar "/tmp/$INSTALLER_JAR" server \
    -mcversion "$MC_VERSION" \
    -loader "$LOADER_VERSION" \
    -dir "$SERVER_DIR" \
    -downloadMinecraft

  rm -f "/tmp/$INSTALLER_JAR"

  save_meta
  echo
  echo "✅ Fabric Server $MC_VERSION (Loader $LOADER_VERSION) instalado correctamente"
  echo "   Jar de inicio: fabric-server-launch.jar"
}

# ==============================
# FORGE (mantenido por compatibilidad)
# ==============================
download_forge() {
  FORGE_META="https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json"
  FORGE_MAVEN="https://maven.minecraftforge.net/net/minecraftforge/forge"

  echo "🔨 Descargando Forge Server (legacy/compatibilidad)..."
  echo

  if [ -n "$MC_VERSION" ]; then
    echo "📄 Versión desde entorno: $MC_VERSION"
  else
    echo "🔎 Obteniendo versiones de Minecraft con soporte Forge..."
    mapfile -t MC_VERSIONS < <(
      curl -s "$FORGE_META" \
        | jq -r 'keys[]' \
        | grep -oP '^[0-9]+\.[0-9]+(\.[0-9]+)?' \
        | sort -Vr | uniq
    )

    if [ "${#MC_VERSIONS[@]}" -eq 0 ]; then
      echo "❌ No se pudieron obtener versiones de Minecraft con Forge"
      exit 1
    fi

    echo "🎮 Versiones disponibles:"
    for i in "${!MC_VERSIONS[@]}"; do
      printf "  [%2d] %s\n" "$i" "${MC_VERSIONS[$i]}"
    done
    echo

    read -rp "👉 Selecciona la versión [0]: " MC_IDX
    MC_VERSION="${MC_VERSIONS[${MC_IDX:-0}]}"

    if [ -z "$MC_VERSION" ]; then
      echo "❌ Selección inválida"
      exit 1
    fi

    export MC_VERSION
  fi

  echo "✅ Minecraft seleccionado: $MC_VERSION"
  echo

  echo "🧱 Tipo de Forge:"
  echo "  [1] Recommended (estable)"
  echo "  [2] Latest (más reciente)"
  echo
  read -rp "👉 Selecciona el tipo [1]: " FORGE_TYPE_INPUT

  case "${FORGE_TYPE_INPUT:-1}" in
    1) FORGE_TYPE="recommended" ;;
    2) FORGE_TYPE="latest" ;;
    *)
      echo "❌ Opción inválida"
      exit 1
      ;;
  esac

  echo "🔎 Resolviendo versión Forge ($FORGE_TYPE)..."
  FORGE_VERSION=$(curl -s "$FORGE_META" \
    | jq -r --arg k "${MC_VERSION}-${FORGE_TYPE}" '.[$k] // empty')

  # Fallback: si no hay recommended, intentar latest
  if [ -z "$FORGE_VERSION" ] && [ "$FORGE_TYPE" = "recommended" ]; then
    echo "⚠️  No hay recommended, probando latest..."
    FORGE_VERSION=$(curl -s "$FORGE_META" \
      | jq -r --arg k "${MC_VERSION}-latest" '.[$k] // empty')
  fi

  if [ -z "$FORGE_VERSION" ]; then
    echo "❌ Forge no disponible para Minecraft $MC_VERSION"
    exit 1
  fi

  echo "✅ Forge: $FORGE_VERSION"
  echo

  INSTALLER="forge-${MC_VERSION}-${FORGE_VERSION}-installer.jar"
  INSTALLER_URL="$FORGE_MAVEN/${MC_VERSION}-${FORGE_VERSION}/${INSTALLER}"

  echo "⬇️  Descargando Forge Installer..."
  wget -q --show-progress -O "/tmp/$INSTALLER" "$INSTALLER_URL"

  echo
  echo "⚙️  Instalando Forge Server..."
  java -jar "/tmp/$INSTALLER" --installServer "$SERVER_DIR"

  rm -f "/tmp/$INSTALLER"

  save_meta
  echo
  echo "✅ Forge $MC_VERSION-$FORGE_VERSION instalado correctamente"
  echo "   El servidor usa: run.sh"
}

# ==============================
# DISPATCH
# ==============================
case "$SERVER_TYPE" in
  vanilla)  download_vanilla  ;;
  papermc)  download_papermc  ;;
  fabric)   download_fabric   ;;
  forge)    download_forge    ;;
  *)
    echo "❌ SERVER_TYPE no definido o inválido: '$SERVER_TYPE'"
    echo "   Valores válidos: vanilla | papermc | fabric | forge"
    exit 1
    ;;
esac

# Ajustar permisos si el usuario minecraft ya existe
if id minecraft &>/dev/null; then
  chown -R minecraft:minecraft /opt/minecraft
fi

echo
echo "📁 Directorio del servidor: $SERVER_DIR"
