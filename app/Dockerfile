# Dockerfile para Flutter - EnglishPro
# Imagen base con Flutter y Android SDK
FROM ghcr.io/cirruslabs/flutter:3.35.4

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración
COPY pubspec.yaml pubspec.lock ./

# Descargar dependencias de Flutter
RUN flutter pub get

# Copiar el código fuente completo
COPY . .

# Configurar para usar el emulador web (más fácil para desarrollo)
# O configurar para conectar con dispositivo físico vía ADB

# Exponer puerto para hot reload
EXPOSE 5000

# Comando por defecto: ejecutar en modo debug con hot reload
CMD ["flutter", "run", "-d", "web-server", "--web-hostname", "0.0.0.0", "--web-port", "5000"]
