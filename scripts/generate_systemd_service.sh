#!/bin/bash
set -e

SERVICE_PATH="/etc/systemd/system/minecraft-forge.service"
SERVER_DIR="/opt/minecraft/server"
JVM_ARGS_FILE="$SERVER_DIR/user_jvm_args.txt"

TOTAL_RAM_MB=$(free -m | awk '/^Mem:/ {print $2}')
TOTAL_RAM_GB=$((TOTAL_RAM_MB / 1024))

echo "🧠 Detección de memoria RAM"
echo "👉 RAM total del sistema: ${TOTAL_RAM_GB} GB"
echo

if [ "$TOTAL_RAM_GB" -lt 6 ]; then
  echo "❌ Forge no es recomendado con menos de 6 GB de RAM"
  exit 1
fi

# Recomendaciones
RECOMMENDED_MAX=$((TOTAL_RAM_GB * 65 / 100))
RECOMMENDED_MIN=$((RECOMMENDED_MAX / 2))

echo "📊 Recomendación para Forge:"
echo "   - RAM mínima: ${RECOMMENDED_MIN}G"
echo "   - RAM máxima: ${RECOMMENDED_MAX}G"
echo

read -rp "🧮 RAM mínima (-Xms) [${RECOMMENDED_MIN}G]: " XMS
XMS=${XMS:-${RECOMMENDED_MIN}G}

read -rp "🧮 RAM máxima (-Xmx) [${RECOMMENDED_MAX}G]: " XMX
XMX=${XMX:-${RECOMMENDED_MAX}G}

echo
echo "⚙️ Generando user_jvm_args.txt..."
echo

cat > "$JVM_ARGS_FILE" <<EOF
-Xms$XMS
-Xmx$XMX
-XX:+UseG1GC
-XX:+ParallelRefProcEnabled
-XX:MaxGCPauseMillis=200
-XX:+UnlockExperimentalVMOptions
-XX:+DisableExplicitGC
EOF

chown minecraft:minecraft "$JVM_ARGS_FILE"

echo "⚙️ Generando minecraft-forge.service..."
echo

cat > "$SERVICE_PATH" <<EOF
[Unit]
Description=Minecraft Forge Server
After=network.target

[Service]
Type=simple
User=minecraft
WorkingDirectory=$SERVER_DIR

ExecStart=$SERVER_DIR/run.sh

Restart=on-failure
RestartSec=15

SuccessExitStatus=0 143
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF

chmod +x "$SERVER_DIR/run.sh"

systemctl daemon-reload
systemctl enable minecraft-forge

echo
echo "✅ Servicio systemd creado correctamente"
echo "👉 Usa: sudo systemctl start minecraft-forge"