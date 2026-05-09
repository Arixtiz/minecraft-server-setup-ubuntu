# 🟩 Minecraft Server Setup for Ubuntu

🚀 Instalación automatizada de servidores Minecraft en Ubuntu mediante Bash scripts.
Soporta **Vanilla**, **PaperMC**, **Fabric** y **Forge** con instalación inteligente de Java según la versión de Minecraft.

---

## ✨ Características

- ⚙️ **Selección de tipo de servidor** — Vanilla, PaperMC, Fabric o Forge
- ☕ **Java automático** — detecta la versión correcta de Java via API de Mojang, con coexistencia de versiones
- 🧵 **Soporte Fabric** — mod loader moderno, ligero y optimizado
- 📄 **Soporte PaperMC** — alto rendimiento con plugins Bukkit/Spigot
- 🟩 **Soporte Vanilla** — servidor oficial de Mojang
- 🔨 **Soporte Forge** — compatibilidad con mods tradicionales
- 📁 Estructura de archivos organizada
- 🔁 Servicio systemd (`minecraft.service`) con auto-start al boot
- 🔐 Configuración inicial segura
- 🖥️ Pensado para Ubuntu Server / VPS / Bare Metal


## ☕ Versiones de Java por Minecraft

El instalador consulta automáticamente la API de Mojang. Si no hay conexión, usa este mapa:

| Versión de Minecraft | Java requerido |
|----------------------|----------------|
| 1.7 – 1.16.x         | Java 8         |
| 1.17.x               | Java 16 / 17   |
| 1.18 – 1.20.4        | Java 17        |
| 1.20.5 en adelante   | Java 21        |
| Futuras versiones    | Consultado via API Mojang |

> Las versiones de Java coexisten en el sistema, se activa la correcta con `update-alternatives`.


## 🧩 Requisitos

### Sistema

- 🐧 Ubuntu 20.04 LTS, 22.04 LTS o superior
- 👤 Usuario con privilegios `sudo`
- 🌐 Acceso a internet

### Dependencias (instaladas automáticamente)

`curl` `wget` `unzip` `ufw` `screen` `jq`

### Hardware recomendado

| Tipo de servidor             | RAM    | CPU     | Almacenamiento |
|------------------------------|--------|---------|----------------|
| Vanilla (1–5 jugadores)      | 2 GB   | 1 vCPU  | 10 GB SSD      |
| PaperMC (5–20 jugadores)     | 4 GB   | 2 vCPU  | 20 GB SSD      |
| Fabric con mods              | 4 GB   | 2 vCPU  | 20 GB SSD      |
| NeoForge (mods modernos)     | 6 GB+  | 2 vCPU+ | 30 GB SSD      |
| Forge (mods pesados)         | 8 GB+  | 4 vCPU+ | 40 GB SSD      |


## 🛠️ Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/Arixtiz/minecraft-server-setup-ubuntu.git
cd minecraft-server-setup-ubuntu
```

### 2. (Opcional) Configurar variables en `.env`

```bash
cp .env.example .env
nano .env
```

```env
SERVER_TYPE=fabric        # vanilla | papermc | fabric | neoforge | forge
MC_VERSION=1.21.4         # opcional, el script lo preguntará si no está
MAX_PLAYERS=20
LEVEL_NAME=world
XMS=2G
XMX=4G
```

### 3. Dar permisos y ejecutar

```bash
chmod +x install.sh
sudo ./install.sh
```

> ⏳ El proceso tarda entre 2 y 5 minutos dependiendo de tu servidor e internet.

El script te guiará paso a paso:
1. Selecciona el tipo de servidor (si no está en `.env`)
2. Selecciona la versión de Minecraft
3. Instala automáticamente la versión correcta de Java
4. Configura el servidor, el servicio systemd y el firewall


## ▶️ Gestión del servidor

```bash
# Iniciar
sudo systemctl start minecraft

# Detener (graceful)
sudo systemctl stop minecraft

# Reiniciar
sudo systemctl restart minecraft

# Ver estado
sudo systemctl status minecraft

# Ver logs en tiempo real
journalctl -u minecraft -f
```


## ⚙️ Configuración

📍 Directorio del servidor:
```
/opt/minecraft/server/
```

Archivos importantes:

| Archivo                      | Descripción                          |
|------------------------------|--------------------------------------|
| `server.properties`          | Configuración principal del servidor |
| `eula.txt`                   | Aceptación de la EULA de Mojang      |
| `mods/`                      | Mods (solo Fabric y Forge)           |
| `/opt/minecraft/.server-meta`| Metadata interna (versión y tipo)    |

Editar configuración:
```bash
nano /opt/minecraft/server/server.properties
```


## 🔐 Seguridad

> ⚠️ **Importante antes de exponer el servidor a internet:**

- 🔓 **Nunca** expongas el puerto 25565 sin configurar el firewall
- 🛑 El servidor corre bajo el usuario `minecraft` (no root)
- 🔑 Usa SSH con llaves, no contraseñas

### Firewall recomendado (UFW)

```bash
sudo ufw allow 22/tcp     # SSH
sudo ufw allow 25565/tcp  # Minecraft
sudo ufw enable
```


## 🧩 Compatibilidad de tipos de servidor

| Tipo      | Estado | Descripción                                      |
|-----------|--------|--------------------------------------------------|
| Vanilla   | ✅     | Servidor oficial de Mojang                       |
| PaperMC   | ✅     | Alto rendimiento + plugins                       |
| Fabric    | ✅     | Mods modernos, ligero y optimizado               |
| NeoForge  | ✅     | Fork moderno de Forge, soporta MC 1.20.2+        |
| Forge     | ✅     | Mods tradicionales (mayor base de mods)          |


## 📛 Advertencias importantes

⚠️ Este script:
- Acepta automáticamente el EULA de Mojang
- Está pensado para Ubuntu limpio (20.04+)
- No incluye sistema de backups por defecto

👉 Úsalo bajo tu propia responsabilidad


## 🧠 Roadmap

- [x] Soporte Vanilla
- [x] Soporte PaperMC
- [x] Soporte Fabric ⭐
- [x] Soporte NeoForge (1.20.2+) ⭐
- [x] Soporte Forge
- [x] Instalación automática de Java según versión de Minecraft
- [x] Coexistencia de múltiples versiones de Java
- [x] Variables de configuración via `.env`
- [ ] Backups automáticos programados
- [ ] Panel web (RCON)
- [ ] Instalación con Docker
- [ ] Notificaciones (Discord webhook)


## 📜 Licencia

MIT License — libre de usar, modificar y distribuir.


## 🤝 Contribuciones

Pull requests e issues son bienvenidos 🙌
Si tienes mejoras, ideas o encuentras un bug, ¡abre un issue!


## ⭐ Soporte

Si este proyecto te fue útil:
- ⭐ Dale una estrella al repo
- 🧑‍💻 Compártelo con otros sysadmins y gamers

---

### Hecho con ❤️ para sysadmins, gamers y developers