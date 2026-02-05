#!/bin/bash

set -e

# Actualizar e instalar SSH
apt-get update -qq
apt-get install -y openssh-server -qq

# Crear usuario de prueba (vulnerable)
useradd -m -s /bin/bash testuser 2>/dev/null || true
echo "testuser:Password123" | chpasswd

# Crear usuario admin
useradd -m -s /bin/bash admin 2>/dev/null || true
echo "admin:Admin2024!" | chpasswd

# Configurar SSH
mkdir -p /var/run/sshd

# Limpiar y configurar SSH correctamente
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Agregar configuraciones adicionales
echo "" >> /etc/ssh/sshd_config
echo "# Custom configuration" >> /etc/ssh/sshd_config
echo "LogLevel VERBOSE" >> /etc/ssh/sshd_config
echo "SyslogFacility AUTH" >> /etc/ssh/sshd_config
echo "AllowUsers testuser admin" >> /etc/ssh/sshd_config

# Iniciar SSH Server
echo "[*] SSH Server iniciando..."
/usr/sbin/sshd -D