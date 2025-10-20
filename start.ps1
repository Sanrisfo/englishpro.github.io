# EnglishPro - Script de Inicio Rápido (PowerShell)
# Este script levanta toda la aplicación con un solo comando

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   EnglishPro - Inicio Rápido" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que Docker está instalado
try {
    docker --version | Out-Null
    docker-compose --version | Out-Null
    Write-Host "✓ Docker detectado" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Docker no está instalado" -ForegroundColor Red
    Write-Host "   Descarga Docker Desktop desde: https://www.docker.com/get-started" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Verificar que existe .env
if (-not (Test-Path .env)) {
    Write-Host "⚠️  Archivo .env no encontrado, creando desde .env.example..." -ForegroundColor Yellow
    Copy-Item .env.example .env
    Write-Host "✓ Archivo .env creado" -ForegroundColor Green
    Write-Host ""
    Write-Host "⚠️  IMPORTANTE: Debes configurar Firebase en el archivo .env" -ForegroundColor Yellow
    Write-Host "   Edita .env y completa las credenciales de Firebase" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "¿Continuar de todas formas? (y/N)"
    if ($continue -ne 'y' -and $continue -ne 'Y') {
        exit 1
    }
}

# Verificar google-services.json
if (-not (Test-Path app/android/app/google-services.json)) {
    Write-Host "⚠️  google-services.json no encontrado" -ForegroundColor Yellow
    if (Test-Path app/android/app/google-services.json.example) {
        Write-Host "   Copiando archivo de ejemplo..." -ForegroundColor Gray
        Copy-Item app/android/app/google-services.json.example app/android/app/google-services.json
        Write-Host "   ⚠️  Debes reemplazar los valores de ejemplo con tu proyecto Firebase" -ForegroundColor Yellow
    }
    Write-Host ""
}

Write-Host "[1/3] Construyendo imágenes Docker..." -ForegroundColor Yellow
Write-Host "      (Esto puede tomar varios minutos la primera vez)" -ForegroundColor Gray
docker-compose build

Write-Host ""
Write-Host "[2/3] Iniciando servicios..." -ForegroundColor Yellow
docker-compose up -d

Write-Host ""
Write-Host "[3/3] Esperando a que los servicios estén listos..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Verificar que los servicios están corriendo
$running = docker ps --format "{{.Names}}"
if ($running -match "englishpro_db" -and $running -match "englishpro_backend" -and $running -match "englishpro_flutter_web") {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "✓ EnglishPro iniciado correctamente" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Servicios disponibles:" -ForegroundColor White
    Write-Host "  📱 Flutter Web:  http://localhost:5000" -ForegroundColor White
    Write-Host "  🔌 Backend API:  http://localhost:8080" -ForegroundColor White
    Write-Host "  🗄️  PostgreSQL:   localhost:5432" -ForegroundColor White
    Write-Host ""
    Write-Host "Usuarios de prueba:" -ForegroundColor White
    Write-Host "  • student@englishpro.com (password: password)" -ForegroundColor Gray
    Write-Host "  • teacher@englishpro.com (password: password)" -ForegroundColor Gray
    Write-Host "  • premium@englishpro.com (password: password)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Ver logs:   docker-compose logs -f" -ForegroundColor Gray
    Write-Host "Detener:    docker-compose down" -ForegroundColor Gray
    Write-Host "=========================================" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "⚠️  Algunos servicios no iniciaron correctamente" -ForegroundColor Yellow
    Write-Host "   Ver logs: docker-compose logs" -ForegroundColor Gray
}
