# Script para iniciar EnglishPro con Docker (PowerShell)

Write-Host "🚀 Iniciando EnglishPro con Docker..." -ForegroundColor Green

# Verificar si existe .env
if (-Not (Test-Path .env)) {
    Write-Host "⚠️  Archivo .env no encontrado. Creando desde .env.example..." -ForegroundColor Yellow
    if (Test-Path .env.example) {
        Copy-Item .env.example .env
        Write-Host "✅ Archivo .env creado. Por favor, configura tus variables de entorno." -ForegroundColor Green
    } else {
        Write-Host "❌ No se encontró .env.example. Creando .env básico..." -ForegroundColor Red
        @"
# Database
DB_PASSWORD=admin123

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-in-production

# Firebase
FIREBASE_PROJECT_ID=your-firebase-project-id
"@ | Out-File -FilePath .env -Encoding UTF8
        Write-Host "✅ Archivo .env básico creado." -ForegroundColor Green
    }
}

# Detener contenedores existentes
Write-Host "🛑 Deteniendo contenedores existentes..." -ForegroundColor Yellow
docker-compose down

# Construir imágenes
Write-Host "🔨 Construyendo imágenes de Docker..." -ForegroundColor Cyan
docker-compose build

# Iniciar servicios
Write-Host "▶️  Iniciando servicios..." -ForegroundColor Green
docker-compose up -d

# Esperar a que PostgreSQL esté listo
Write-Host "⏳ Esperando a que PostgreSQL esté listo..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Verificar estado de los contenedores
Write-Host ""
Write-Host "📊 Estado de los contenedores:" -ForegroundColor Cyan
docker-compose ps

Write-Host ""
Write-Host "✅ EnglishPro iniciado correctamente!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Información de servicios:" -ForegroundColor White
Write-Host "   - PostgreSQL: localhost:5432" -ForegroundColor Gray
Write-Host "   - Backend API: http://localhost:8080" -ForegroundColor Gray
Write-Host ""
Write-Host "📋 Comandos útiles:" -ForegroundColor White
Write-Host "   - Ver logs: docker-compose logs -f" -ForegroundColor Gray
Write-Host "   - Detener: docker-compose down" -ForegroundColor Gray
Write-Host "   - Reiniciar: docker-compose restart" -ForegroundColor Gray
Write-Host "   - Ver BD: docker exec -it englishpro_db psql -U admin -d englishpro_db" -ForegroundColor Gray
