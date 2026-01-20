#!/bin/bash
set -e

echo "🧠 Instalador inteligente de Java para Minecraft / Forge"
echo

# ==============================
# 1️⃣ OBTENER VERSION DE MINECRAFT
# ==============================

if [ -f "./forge-version.txt" ]; then
  MC_VERSION=$(cat forge-version.txt)
  echo "📄 Versión detectada desde forge-version.txt: $MC_VERSION"
else
  read -rp "🎮 Ingresa la versión de Minecraft (ej: 1.20.1, 1.21.1): " MC_VERSION
fi

if [[ ! $MC_VERSION =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
  echo "❌ Versión inválida"
  exit 1
fi

MAJOR=$(echo "$MC_VERSION" | cut -d. -f1)
MINOR=$(echo "$MC_VERSION" | cut -d. -f2)
PATCH=$(echo "$MC_VERSION" | cut -d. -f3)
PATCH=${PATCH:-0}

echo "🔍 Analizando versión: $MAJOR.$MINOR.$PATCH"
echo

# ==============================
# 2️⃣ DECIDIR JAVA
# ==============================

JAVA_VERSION=""

if (( MAJOR == 1 && MINOR <= 16 )); then
  JAVA_VERSION=8
elif (( MAJOR == 1 && MINOR <= 20 && PATCH <= 4 )); then
  JAVA_VERSION=17
else
  JAVA_VERSION=21
fi

echo "☕ Java requerido: Java $JAVA_VERSION"
echo

# ==============================
# 3️⃣ LIMPIAR JAVAS ANTERIORES
# ==============================

echo "🧹 Eliminando versiones antiguas de Java..."
apt remove --purge -y openjdk-* || true
apt autoremove -y

# ==============================
# 4️⃣ INSTALAR JAVA CORRECTO
# ==============================

echo "⬇️ Instalando OpenJDK $JAVA_VERSION..."

apt update
apt install -y openjdk-${JAVA_VERSION}-jre-headless

# ==============================
# 5️⃣ CONFIGURAR ALTERNATIVAS
# ==============================

echo "🔁 Configurando Java por defecto..."
update-alternatives --auto java

# ==============================
# 6️⃣ VERIFICACIÓN
# ==============================

echo
echo "✅ Instalación completada"
java -version