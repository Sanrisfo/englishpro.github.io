#!/bin/bash

# Script para iniciar EnglishPro con Docker

echo "🚀 Iniciando EnglishPro con Docker..."

# Verificar si existe .env
if [ ! -f .env ]; then
    echo "⚠️  Archivo .env no encontrado. Creando desde .env.example..."
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "✅ Archivo .env creado. Por favor, configura tus variables de entorno."
    else
        echo "❌ No se encontró .env.example. Creando .env básico..."
        cat > .env << EOF
# Database
DB_PASSWORD=admin123

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-in-production

# Firebase
FIREBASE_PROJECT_ID=your-firebase-project-id
EOF
        echo "✅ Archivo .env básico creado."
    fi
fi

# Detener contenedores existentes
echo "🛑 Deteniendo contenedores existentes..."
docker-compose down

# Construir imágenes
echo "🔨 Construyendo imágenes de Docker..."
docker-compose build

# Iniciar servicios
echo "▶️  Iniciando servicios..."
docker-compose up -d

# Esperar a que PostgreSQL esté listo
echo "⏳ Esperando a que PostgreSQL esté listo..."
sleep 5

# Verificar estado de los contenedores
echo ""
echo "📊 Estado de los contenedores:"
docker-compose ps

echo ""
echo "✅ EnglishPro iniciado correctamente!"
echo ""
echo "📝 Información de servicios:"
echo "   - PostgreSQL: localhost:5432"
echo "   - Backend API: http://localhost:8080"
echo ""
echo "📋 Comandos útiles:"
echo "   - Ver logs: docker-compose logs -f"
echo "   - Detener: docker-compose down"
echo "   - Reiniciar: docker-compose restart"
echo "   - Ver BD: docker exec -it englishpro_db psql -U admin -d englishpro_db"
