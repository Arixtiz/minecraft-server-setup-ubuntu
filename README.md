# 🟩 Minecraft Server Setup for Ubuntu

🚀 Automated setup for a Minecraft server on Ubuntu using Bash scripts.
Instala y configura un servidor de Minecraft de forma rápida, segura y reproducible, listo para producción o uso personal.

## ✨ Características
-	⚙️ Instalación automática de Java (OpenJDK)
-	🧱 Soporte para Vanilla y PaperMC
-	📁 Estructura de archivos organizada
-	🔁 Servicio systemd (auto-start al boot)
-	🔐 Configuración inicial segura
-	📝 Logs centralizados
-	🖥️ Pensado para Ubuntu Server / VPS / Bare Metal


## 🧩 Requisitos

### Sistema

-	🐧 Ubuntu 20.04 LTS, 22.04 LTS o superior
-	👤 Usuario con privilegios sudo
-	🌐 Acceso a internet

### Hardware recomendado

| Tipo de servidor            | RAM   | CPU     | Almacenamiento |
|-----------------------------|-------|---------|----------------|
| Vanilla (1–5 jugadores)     | 2 GB  | 1 vCPU  | 10 GB SSD     |
| Paper (5–15 jugadores)      | 4 GB  | 2 vCPU  | 20 GB SSD     |
| Modded / Alta carga         | 8 GB+ | 4 vCPU+ | 40 GB SSD     |


### 📦 ¿Qué instala el script?
-	openjdk-17-jre-headless
-	Carpeta dedicada para Minecraft (/opt/minecraft)
-	Usuario del sistema: minecraft
-	Archivo server.properties
-	Servicio minecraft.service


## 🛠️ Instalación

1. Clonar el repositorio

```bash
git clone https://github.com/Arixtiz/minecraft-server-setup-ubuntu.git
cd minecraft-server-setup-ubuntu
```

2. Dar permisos de ejecución
```bash
chmod +x install.sh
```
3. Ejecutar instalación
```bash
sudo ./install.sh
```

⏳ El proceso tarda entre 1 y 3 minutos dependiendo del servidor.


## ▶️ Uso del servidor

Iniciar el servidor
```
sudo systemctl start minecraft
```
Detener el servidor
```
sudo systemctl stop minecraft
```
Ver estado
```
sudo systemctl status minecraft
```
Ver logs en tiempo real
```
journalctl -u minecraft -f
```

## ⚙️ Configuración

📍 Ubicación del servidor:
```
/opt/minecraft/server
```

Archivos importantes:
-	server.properties
-	eula.txt
-	logs/

Después de la primera ejecución:
```
nano /opt/minecraft/server/server.properties
```

## 🔐 Seguridad (Muy importante)

⚠️ WARNING
-	🔓 NO expongas el puerto 25565 sin firewall
-	🛑 Nunca ejecutes Minecraft como root
-	🔑 Usa SSH con llaves, no contraseñas

Firewall recomendado (UFW)
```
sudo ufw allow 22
sudo ufw allow 25565
sudo ufw enable
```


## 📛 Advertencias importantes

⚠️ Este script:
-	Acepta automáticamente el EULA de Mojang
-	Está pensado para Ubuntu limpio
-	No incluye backups por defecto

👉 Úsalo bajo tu propia responsabilidad

### 🧠 Roadmap
-	Backups automáticos
-	Soporte Forge / Fabric
-	Variables por .env
-	Instalación con Docker
-	Panel web (RCON)

### 🧪 Compatibilidad
-	✅ Vanilla Minecraft
-	✅ PaperMC
-	❌ Forge (por ahora)
-	❌ Fabric (por ahora)

## 📜 Licencia

MIT License — libre de usar, modificar y distribuir.


## 🤝 Contribuciones

Pull requests y issues son bienvenidos 🙌
Si tienes mejoras, ideas o bugs, ¡abre un issue!

## ⭐ Soporte

Si este proyecto te fue útil:
	•	⭐ Dale una estrella al repo
	•	🧑‍💻 Compártelo


### Hecho con ❤️ para sysadmins, gamers y developers