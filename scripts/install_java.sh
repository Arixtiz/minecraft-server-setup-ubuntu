#!/bin/bash
set -e

echo "☕ Instalador inteligente de Java para Minecraft"
echo "================================================="
echo

MOJANG_MANIFEST="https://launchermeta.mojang.com/mc/game/version_manifest_v2.json"
META_FILE="/opt/minecraft/.server-meta"

# ==============================
# 1️⃣ OBTENER VERSIÓN DE MINECRAFT
# ==============================

if [ -f "$META_FILE" ]; then
  source "$META_FILE"
  echo "📄 Versión detectada desde metadata: $MC_VERSION"
elif [ -n "$MC_VERSION" ]; then
  echo "📄 Versión desde entorno: $MC_VERSION"
else
  read -rp "🎮 Ingresa la versión de Minecraft (ej: 1.21.4): " MC_VERSION
fi

if [[ ! $MC_VERSION =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
  echo "❌ Versión inválida: $MC_VERSION"
  exit 1
fi

echo "🔍 Versión objetivo: $MC_VERSION"
echo

# ==============================
# 2️⃣ CONSULTAR JAVA REQUERIDO (API Mojang)
# ==============================

JAVA_VERSION=""

echo "🌐 Consultando versión de Java requerida desde Mojang..."
VERSION_URL=$(curl -s --connect-timeout 10 "$MOJANG_MANIFEST" \
  | jq -r --arg v "$MC_VERSION" '.versions[] | select(.id == $v) | .url' 2>/dev/null || echo "")

if [ -n "$VERSION_URL" ]; then
  JAVA_VERSION=$(curl -s --connect-timeout 10 "$VERSION_URL" \
    | jq -r '.javaVersion.majorVersion // empty' 2>/dev/null || echo "")
  if [ -n "$JAVA_VERSION" ]; then
    echo "✅ Java requerido según Mojang API: Java $JAVA_VERSION"
  fi
fi

# ==============================
# 3️⃣ FALLBACK — MAPA ESTÁTICO
# ==============================

if [ -z "$JAVA_VERSION" ]; then
  echo "⚠️  No se pudo consultar la API, usando mapa de versiones estático..."

  MAJOR=$(echo "$MC_VERSION" | cut -d. -f1)
  MINOR=$(echo "$MC_VERSION" | cut -d. -f2)
  PATCH=$(echo "$MC_VERSION" | cut -d. -f3)
  PATCH=${PATCH:-0}

  if   (( MAJOR == 1 && MINOR <= 16 ));                          then JAVA_VERSION=8
  elif (( MAJOR == 1 && MINOR == 17 ));                          then JAVA_VERSION=16
  elif (( MAJOR == 1 && MINOR >= 18 && MINOR <= 20 && PATCH <= 4 )); then JAVA_VERSION=17
  else
    JAVA_VERSION=21
  fi

  echo "☕ Java requerido (mapa estático): Java $JAVA_VERSION"
fi

echo

# ==============================
# 4️⃣ VERIFICAR SI YA ESTÁ INSTALADO Y ACTIVO
# ==============================

CURRENT_JAVA=""
if command -v java &>/dev/null; then
  RAW=$(java -version 2>&1 | grep -oP 'version "([0-9]+)' | grep -oP '[0-9]+$')
  # Java 8 se reporta como "1.8" → extraer el 8
  if [ "$RAW" = "1" ]; then
    CURRENT_JAVA=8
  else
    CURRENT_JAVA="$RAW"
  fi
  echo "ℹ️  Java activo actualmente: Java $CURRENT_JAVA"
fi

if [ "$CURRENT_JAVA" = "$JAVA_VERSION" ]; then
  echo "✅ Java $JAVA_VERSION ya está activo. No es necesario reinstalar."
  java -version
  exit 0
fi

echo

# ==============================
# 5️⃣ INSTALAR JAVA SIN ELIMINAR OTROS
# ==============================

echo "⬇️  Instalando OpenJDK $JAVA_VERSION (coexistencia con otras versiones)..."
apt update -qq

case "$JAVA_VERSION" in
  8)
    apt install -y openjdk-8-jre-headless
    ;;
  16)
    # Java 16 ya no está en repos modernos de Ubuntu, usar 17 como fallback
    if apt-cache show openjdk-16-jre-headless &>/dev/null; then
      apt install -y openjdk-16-jre-headless
    else
      echo "⚠️  OpenJDK 16 no disponible en este sistema, instalando Java 17 (compatible con 1.17)"
      apt install -y openjdk-17-jre-headless
      JAVA_VERSION=17
    fi
    ;;
  *)
    apt install -y "openjdk-${JAVA_VERSION}-jre-headless"
    ;;
esac

echo

# ==============================
# 6️⃣ CONFIGURAR COMO VERSIÓN ACTIVA (update-alternatives)
# ==============================

echo "🔁 Configurando Java $JAVA_VERSION como versión activa..."

# Buscar la ruta exacta del binario recién instalado
JAVA_BIN=$(update-alternatives --list java 2>/dev/null \
  | grep -E "java-${JAVA_VERSION}" | head -1)

if [ -n "$JAVA_BIN" ]; then
  update-alternatives --set java "$JAVA_BIN"
  echo "✅ Java $JAVA_VERSION configurado como activo: $JAVA_BIN"
else
  echo "⚠️  No se encontró la alternativa exacta, dejando en modo automático"
  update-alternatives --auto java
fi

echo
echo "✅ Instalación de Java completada"
java -version