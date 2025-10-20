#!/bin/bash
# EnglishPro - Script de Inicio Rápido
# Este script levanta toda la aplicación con un solo comando

set -e

echo "========================================="
echo "   EnglishPro - Inicio Rápido"
echo "========================================="
echo ""

# Verificar que Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker no está instalado"
    echo "   Descarga Docker desde: https://www.docker.com/get-started"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: Docker Compose no está instalado"
    exit 1
fi

echo "✓ Docker detectado"
echo ""

# Verificar que existe .env
if [ ! -f .env ]; then
    echo "⚠️  Archivo .env no encontrado, creando desde .env.example..."
    cp .env.example .env
    echo "✓ Archivo .env creado"
    echo ""
    echo "⚠️  IMPORTANTE: Debes configurar Firebase en el archivo .env"
    echo "   Edita .env y completa las credenciales de Firebase"
    echo ""
    read -p "¿Continuar de todas formas? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Verificar google-services.json
if [ ! -f app/android/app/google-services.json ]; then
    echo "⚠️  google-services.json no encontrado"
    if [ -f app/android/app/google-services.json.example ]; then
        echo "   Copiando archivo de ejemplo..."
        cp app/android/app/google-services.json.example app/android/app/google-services.json
        echo "   ⚠️  Debes reemplazar los valores de ejemplo con tu proyecto Firebase"
    fi
    echo ""
fi

echo "[1/3] Construyendo imágenes Docker..."
echo "      (Esto puede tomar varios minutos la primera vez)"
docker-compose build

echo ""
echo "[2/3] Iniciando servicios..."
docker-compose up -d

echo ""
echo "[3/3] Esperando a que los servicios estén listos..."
sleep 5

# Verificar que los servicios están corriendo
if docker ps | grep -q englishpro_db && \
   docker ps | grep -q englishpro_backend && \
   docker ps | grep -q englishpro_flutter_web; then
    echo ""
    echo "========================================="
    echo "✓ EnglishPro iniciado correctamente"
    echo "========================================="
    echo ""
    echo "Servicios disponibles:"
    echo "  📱 Flutter Web:  http://localhost:5000"
    echo "  🔌 Backend API:  http://localhost:8080"
    echo "  🗄️  PostgreSQL:   localhost:5432"
    echo ""
    echo "Usuarios de prueba:"
    echo "  • student@englishpro.com (password: password)"
    echo "  • teacher@englishpro.com (password: password)"
    echo "  • premium@englishpro.com (password: password)"
    echo ""
    echo "Ver logs:   docker-compose logs -f"
    echo "Detener:    docker-compose down"
    echo "========================================="
else
    echo ""
    echo "⚠️  Algunos servicios no iniciaron correctamente"
    echo "   Ver logs: docker-compose logs"
fi
