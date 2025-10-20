#!/bin/bash
# EnglishPro - Script de Inicialización de Base de Datos
# Este script crea las tablas y carga datos de prueba automáticamente

set -e

echo "========================================="
echo "EnglishPro - Inicialización de BD"
echo "========================================="

# Variables de entorno (se leen del .env)
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-englishpro_db}"
DB_USER="${DB_USER:-admin}"
DB_PASSWORD="${DB_PASSWORD:-admin123}"

echo "Configuración:"
echo "  Host: $DB_HOST"
echo "  Puerto: $DB_PORT"
echo "  Base de datos: $DB_NAME"
echo "  Usuario: $DB_USER"
echo ""

# Esperar a que PostgreSQL esté listo
echo "[1/4] Esperando a que PostgreSQL esté listo..."
until PGPASSWORD=$DB_PASSWORD psql -h "$DB_HOST" -U "$DB_USER" -d postgres -c '\q' 2>/dev/null; do
  echo "  PostgreSQL no está listo - esperando..."
  sleep 2
done
echo "  ✓ PostgreSQL está listo"
echo ""

# Crear base de datos si no existe
echo "[2/4] Verificando base de datos..."
PGPASSWORD=$DB_PASSWORD psql -h "$DB_HOST" -U "$DB_USER" -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 || \
PGPASSWORD=$DB_PASSWORD psql -h "$DB_HOST" -U "$DB_USER" -d postgres -c "CREATE DATABASE $DB_NAME"
echo "  ✓ Base de datos verificada: $DB_NAME"
echo ""

# Ejecutar schema.sql
echo "[3/4] Creando tablas (schema.sql)..."
PGPASSWORD=$DB_PASSWORD psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f "$(dirname "$0")/schema.sql"
echo "  ✓ Tablas creadas exitosamente"
echo ""

# Ejecutar seed.sql
echo "[4/4] Insertando datos de prueba (seed.sql)..."
PGPASSWORD=$DB_PASSWORD psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f "$(dirname "$0")/seed.sql"
echo "  ✓ Datos de prueba insertados"
echo ""

echo "========================================="
echo "✓ Inicialización completada exitosamente"
echo "========================================="
echo ""
echo "Usuarios de prueba creados:"
echo "  • student@englishpro.com (password: password)"
echo "  • teacher@englishpro.com (password: password)"
echo "  • premium@englishpro.com (password: password)"
echo ""
echo "Puedes conectarte a la BD con:"
echo "  psql -h $DB_HOST -U $DB_USER -d $DB_NAME"
echo ""
