#!/bin/bash
set -e

SERVICE_PATH="/etc/systemd/system/minecraft-forge.service"
SERVER_DIR="/opt/minecraft/server"

TOTAL_RAM_MB=$(free -m | awk '/^Mem:/ {print $2}')
TOTAL_RAM_GB=$((TOTAL_RAM_MB / 1024))

echo "🧠 Detección de memoria RAM"
echo "👉 RAM total del sistema: ${TOTAL_RAM_GB} GB"
echo

if [ "$TOTAL_RAM_GB" -lt 6 ]; then
  echo "❌ Forge no es recomendado con menos de 6 GB de RAM"
  exit 1
fi

# Recomendación
RECOMMENDED_MAX=$((TOTAL_RAM_GB * 65 / 100))
RECOMMENDED_MIN=$((RECOMMENDED_MAX / 2))

echo "📊 Recomendación para Forge:"
echo "   - RAM mínima: ${RECOMMENDED_MIN}G"
echo "   - RAM máxima: ${RECOMMENDED_MAX}G"
echo

# Preguntar al usuario
read -rp "🧮 RAM mínima (-Xms) [${RECOMMENDED_MIN}G]: " XMS
XMS=${XMS:-${RECOMMENDED_MIN}G}

read -rp "🧮 RAM máxima (-Xmx) [${RECOMMENDED_MAX}G]: " XMX
XMX=${XMX:-${RECOMMENDED_MAX}G}

echo
echo "⚙️ Generando minecraft-forge.service..."
echo

cat > "$SERVICE_PATH" <<EOF
[Unit]
Description=Minecraft Forge Server
After=network.target

[Service]
User=minecraft
WorkingDirectory=$SERVER_DIR

ExecStart=/usr/bin/java \\
  -Xms$XMS \\
  -Xmx$XMX \\
  -XX:+UseG1GC \\
  -XX:+ParallelRefProcEnabled \\
  -XX:MaxGCPauseMillis=200 \\
  -XX:+UnlockExperimentalVMOptions \\
  -XX:+DisableExplicitGC \\
  -jar forge-*.jar nogui

Restart=on-failure
RestartSec=15

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable minecraft-forge

echo "✅ Servicio systemd creado correctamente"
echo "👉 Usa: sudo systemctl start minecraft-forge"