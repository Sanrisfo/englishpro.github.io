# EnglishPro Flutter App - Dockerfile
# Imagen base para Flutter development y web deployment

FROM ubuntu:22.04

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias base
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-11-jdk \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Configurar variables de entorno para Flutter
ENV FLUTTER_HOME=/opt/flutter
ENV FLUTTER_VERSION=3.35.4
ENV PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"

# Descargar e instalar Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME && \
    flutter --version && \
    flutter doctor && \
    flutter config --enable-web

# Configurar variables de entorno para Android
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=$ANDROID_HOME
ENV PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# Descargar e instalar Android SDK command-line tools
RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    cd $ANDROID_HOME/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip commandlinetools-linux-9477386_latest.zip && \
    rm commandlinetools-linux-9477386_latest.zip && \
    mv cmdline-tools latest

# Aceptar licencias de Android SDK
RUN yes | sdkmanager --licenses || true

# Instalar platform-tools y build-tools
RUN sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Crear directorio de trabajo
WORKDIR /app

# Copiar pubspec files primero (para aprovechar cache de Docker)
COPY pubspec.yaml pubspec.lock ./

# Obtener dependencias
RUN flutter pub get

# Copiar el resto de la aplicación
COPY . .

# Exponer puerto para Flutter web
EXPOSE 8080

# Comando por defecto: correr en modo web
CMD ["flutter", "run", "-d", "web-server", "--web-port=8080", "--web-hostname=0.0.0.0"]
