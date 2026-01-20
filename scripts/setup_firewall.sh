#!/bin/bash

echo "🔐 Configurando UFW..."
ufw allow OpenSSH
ufw allow 25565/tcp
ufw --force enable