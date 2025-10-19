# Используем официальный образ OpenJDK для сборки
FROM gradle:8.11-jdk17 AS builder

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы конфигурации Gradle
COPY build.gradle.kts settings.gradle.kts gradle.properties ./
COPY gradle gradle

# Копируем исходный код
COPY src src

# Собираем приложение
RUN gradle build --no-daemon

# Финальный образ для запуска
FROM eclipse-temurin:17-jre-alpine

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем собранный JAR файл
COPY --from=builder /app/build/libs/*.jar app.jar

# Открываем порт
EXPOSE 8060

# Устанавливаем переменные окружения для подключения к MinIO
ENV MINIO_ENDPOINT=http://minio:9000
ENV MINIO_ACCESS_KEY=minioadmin
ENV MINIO_SECRET_KEY=minioadmin
ENV MINIO_BUCKET_NAME=files

# Запускаем приложение
CMD ["java", "-jar", "app.jar"]
