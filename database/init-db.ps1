# EnglishPro - Script de Inicialización de Base de Datos (PowerShell)
# Este script crea las tablas y carga datos de prueba automáticamente

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "EnglishPro - Inicialización de BD" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Variables de entorno
$DB_HOST = if ($env:DB_HOST) { $env:DB_HOST } else { "localhost" }
$DB_PORT = if ($env:DB_PORT) { $env:DB_PORT } else { "5432" }
$DB_NAME = if ($env:DB_NAME) { $env:DB_NAME } else { "englishpro_db" }
$DB_USER = if ($env:DB_USER) { $env:DB_USER } else { "admin" }
$DB_PASSWORD = if ($env:DB_PASSWORD) { $env:DB_PASSWORD } else { "admin123" }

Write-Host "Configuración:"
Write-Host "  Host: $DB_HOST"
Write-Host "  Puerto: $DB_PORT"
Write-Host "  Base de datos: $DB_NAME"
Write-Host "  Usuario: $DB_USER"
Write-Host ""

# Esperar a que PostgreSQL esté listo
Write-Host "[1/4] Esperando a que PostgreSQL esté listo..." -ForegroundColor Yellow
$env:PGPASSWORD = $DB_PASSWORD
$maxRetries = 30
$retry = 0
while ($retry -lt $maxRetries) {
    try {
        docker exec englishpro_db psql -U $DB_USER -d postgres -c '\q' 2>$null
        Write-Host "  ✓ PostgreSQL está listo" -ForegroundColor Green
        break
    } catch {
        Write-Host "  PostgreSQL no está listo - esperando..." -ForegroundColor Gray
        Start-Sleep -Seconds 2
        $retry++
    }
}
Write-Host ""

# Crear tablas
Write-Host "[2/4] Creando tablas (schema.sql)..." -ForegroundColor Yellow
docker exec -i englishpro_db psql -U $DB_USER -d $DB_NAME < database/schema.sql
Write-Host "  ✓ Tablas creadas exitosamente" -ForegroundColor Green
Write-Host ""

# Insertar datos
Write-Host "[3/4] Insertando datos de prueba (seed.sql)..." -ForegroundColor Yellow
docker exec -i englishpro_db psql -U $DB_USER -d $DB_NAME < database/seed.sql
Write-Host "  ✓ Datos de prueba insertados" -ForegroundColor Green
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "✓ Inicialización completada exitosamente" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Usuarios de prueba creados:"
Write-Host "  • student@englishpro.com (password: password)" -ForegroundColor White
Write-Host "  • teacher@englishpro.com (password: password)" -ForegroundColor White
Write-Host "  • premium@englishpro.com (password: password)" -ForegroundColor White
Write-Host ""
Write-Host "Puedes conectarte a la BD con:"
Write-Host "  docker exec -it englishpro_db psql -U $DB_USER -d $DB_NAME" -ForegroundColor Gray
Write-Host ""
