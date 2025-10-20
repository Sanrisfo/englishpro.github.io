# Usar imagen oficial de Dart
FROM dart:3.9.2-sdk

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY pubspec.yaml pubspec.lock ./

# Descargar dependencias
RUN dart pub get

# Copiar el código fuente
COPY . .

# Exponer el puerto
EXPOSE 8080

# Comando para ejecutar el servidor en modo JIT
CMD ["dart", "run", "bin/server.dart"]
