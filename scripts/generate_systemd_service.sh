#!/bin/bash
set -e

SERVICE_PATH="/etc/systemd/system/minecraft.service"
SERVER_DIR="/opt/minecraft/server"
META_FILE="/opt/minecraft/.server-meta"

# Cargar metadata del servidor
if [ -f "$META_FILE" ]; then
  source "$META_FILE"
fi

echo "⚙️  Generando servicio systemd para: ${SERVER_TYPE:-vanilla}"
echo

# ==============================
# Calcular RAM recomendada
# ==============================
TOTAL_RAM_MB=$(free -m | awk '/^Mem:/ {print $2}')
TOTAL_RAM_GB=$((TOTAL_RAM_MB / 1024))

echo "🧠 RAM total del sistema: ${TOTAL_RAM_GB} GB"

# Recomendaciones según tipo
case "$SERVER_TYPE" in
  forge)
    MIN_RAM_GB=6
    ;;
  fabric)
    MIN_RAM_GB=2
    ;;
  *)
    MIN_RAM_GB=1
    ;;
esac

if [ "$TOTAL_RAM_GB" -lt "$MIN_RAM_GB" ]; then
  echo "⚠️  Advertencia: se recomiendan al menos ${MIN_RAM_GB} GB de RAM para $SERVER_TYPE (tienes ${TOTAL_RAM_GB} GB)"
fi

RECOMMENDED_MAX=$((TOTAL_RAM_GB * 65 / 100))
RECOMMENDED_MIN=$((RECOMMENDED_MAX / 2))

# Garantizar mínimos absolutos
[ "$RECOMMENDED_MAX" -lt 1 ] && RECOMMENDED_MAX=1
[ "$RECOMMENDED_MIN" -lt 1 ] && RECOMMENDED_MIN=1

echo "📊 Recomendación de RAM:"
echo "   - Mínima (-Xms): ${RECOMMENDED_MIN}G"
echo "   - Máxima (-Xmx): ${RECOMMENDED_MAX}G"
echo

if [ -n "$XMS" ]; then
  echo "📄 XMS desde entorno: $XMS"
else
  read -rp "🧮 RAM mínima (-Xms) [${RECOMMENDED_MIN}G]: " XMS
  XMS=${XMS:-${RECOMMENDED_MIN}G}
fi

if [ -n "$XMX" ]; then
  echo "📄 XMX desde entorno: $XMX"
else
  read -rp "🧮 RAM máxima (-Xmx) [${RECOMMENDED_MAX}G]: " XMX
  XMX=${XMX:-${RECOMMENDED_MAX}G}
fi

echo

# ==============================
# Determinar comando de inicio según tipo
# ==============================
case "$SERVER_TYPE" in
  vanilla | papermc)
    EXEC_START="/usr/bin/java -Xms${XMS} -Xmx${XMX} \
-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
-XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC \
-jar ${SERVER_DIR}/server.jar nogui"
    ;;
  fabric)
    EXEC_START="/usr/bin/java -Xms${XMS} -Xmx${XMX} \
-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
-XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC \
-jar ${SERVER_DIR}/fabric-server-launch.jar nogui"
    ;;
  forge | neoforge)
    # Forge/NeoForge generan su propio run.sh durante la instalación
    EXEC_START="${SERVER_DIR}/run.sh"
    ;;
  *)
    EXEC_START="/usr/bin/java -Xms${XMS} -Xmx${XMX} -jar ${SERVER_DIR}/server.jar nogui"
    ;;
esac

# ==============================
# Generar minecraft.service
# ==============================
echo "📝 Generando $SERVICE_PATH..."

cat > "$SERVICE_PATH" <<EOF
[Unit]
Description=Minecraft Server (${SERVER_TYPE})
After=network.target

[Service]
Type=simple
User=minecraft
WorkingDirectory=${SERVER_DIR}

ExecStart=${EXEC_START}

Restart=on-failure
RestartSec=15

SuccessExitStatus=0 143
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF

# Para Forge/NeoForge, asegurarse que run.sh sea ejecutable
if [[ "$SERVER_TYPE" == "forge" || "$SERVER_TYPE" == "neoforge" ]] && [ -f "$SERVER_DIR/run.sh" ]; then
  chmod +x "$SERVER_DIR/run.sh"
fi

systemctl daemon-reload

echo
echo "✅ Servicio minecraft.service creado correctamente"
echo "👉 Usa: sudo systemctl start minecraft"