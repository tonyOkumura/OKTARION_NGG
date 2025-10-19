# Микросервис Файлов (File Microservice)

Микросервис для управления файлами, построенный на Ktor с MinIO объектным хранилищем. Этот проект готов для реализации функционала работы с файлами.

## 🚀 Особенности

- **Ktor Framework** - современный фреймворк для Kotlin
- **MinIO** - высокопроизводительное объектное хранилище, совместимое с Amazon S3
- **Docker** - контейнеризация для простого развертывания
- **REST API** - готов к реализации CRUD операций для файлов
- **JSON Serialization** - автоматическая сериализация/десериализация
- **Health Checks** - мониторинг состояния сервиса (`/health`, `/health/ready`, `/health/live`)
- **Structured Logging** - логирование с корреляционными ID
- **Security Headers** - базовые заголовки безопасности (HSTS, XSS Protection, etc.)
- **CORS Support** - поддержка кросс-доменных запросов
- **Request Validation** - валидация входных данных с детальными ошибками
- **Graceful Shutdown** - корректное завершение работы
- **Environment Configuration** - конфигурация через переменные окружения
- **Structured Error Handling** - единая структура ошибок API
- **Centralized Configuration** - централизованная конфигурация через `AppConfig`
- **Clean Architecture** - организованная файловая структура по слоям

## ⚙️ Конфигурация

### Переменные окружения

Микросервис поддерживает конфигурацию через переменные окружения. Скопируйте `env.example` в `.env` и настройте под ваши нужды:

```bash
cp env.example .env
```

### Основные параметры:

| Переменная | Описание | Значение по умолчанию |
|------------|----------|----------------------|
| **SERVER_PORT** | Порт сервера | 8060 |
| **SERVER_HOST** | Хост сервера | 0.0.0.0 |
| **ENVIRONMENT** | Окружение | development |
| **MINIO_ENDPOINT** | URL MinIO сервера | http://minio:9000 |
| **MINIO_ACCESS_KEY** | Ключ доступа MinIO | minioadmin |
| **MINIO_SECRET_KEY** | Секретный ключ MinIO | minioadmin |
| **MINIO_BUCKET_NAME** | Имя bucket для файлов | files |
| **MINIO_REGION** | Регион MinIO | us-east-1 |
| **LOG_LEVEL** | Уровень логирования | INFO |
| **LOG_CORRELATION_ID** | Включить корреляционные ID | true |
| **CORS_ENABLED** | Включить CORS | true |
| **CORS_ORIGINS** | Разрешенные источники | * |
| **RATE_LIMIT_ENABLED** | Включить rate limiting | true |
| **RATE_LIMIT_REQUESTS** | Лимит запросов | 100 |
| **RATE_LIMIT_WINDOW_MINUTES** | Окно лимита (минуты) | 1 |

## 📡 API Endpoints

### Базовые endpoints

| Метод | Путь | Описание | Статус |
|-------|------|----------|--------|
| GET | `/` | Проверка работы сервиса | ✅ |

### Health Check endpoints

| Метод | Путь | Описание | Статус |
|-------|------|----------|--------|
| GET | `/health` | Общий статус здоровья | ✅ |
| GET | `/health/ready` | Готовность к работе | ✅ |
| GET | `/health/live` | Проверка живости | ✅ |

### Примеры запросов

**Проверка работы сервиса:**
```bash
curl http://localhost:8060/
```

**Проверка здоровья:**
```bash
curl http://localhost:8060/health
```

## 🐳 Запуск с Docker

### Быстрый старт

1. Клонируйте репозиторий
2. Скопируйте файл конфигурации:
```bash
cp env.example .env
```

3. Запустите сервисы:
```bash
docker-compose up --build -d
```

4. Сервис будет доступен по адресу: http://localhost:8060
5. MinIO Console будет доступна по адресу: http://localhost:9301

### Управление сервисами

**Остановка сервисов:**
```bash
docker-compose down
```

**Очистка данных:**
```bash
docker-compose down -v
```

**Просмотр логов:**
```bash
docker-compose logs -f file-service
```

**Перезапуск сервиса:**
```bash
docker-compose restart file-service
```

## 💻 Локальная разработка

### Требования

- Java 17+
- Gradle 8.5+
- MinIO (через Docker или локальная установка)

### Настройка MinIO

1. Запустите MinIO локально:
```bash
docker run -p 9300:9000 -p 9301:9001 \
  -e MINIO_ROOT_USER=minioadmin \
  -e MINIO_ROOT_PASSWORD=minioadmin \
  minio/minio server /data --console-address ":9001"
```

2. Или используйте Docker Compose только для MinIO:
```bash
docker-compose up minio -d
```

### Запуск приложения

**Сборка проекта:**
```bash
./gradlew build
```

**Запуск приложения:**
```bash
./gradlew run
```

**Запуск с переменными окружения:**
```bash
export MINIO_ENDPOINT="http://localhost:9300"
export MINIO_ACCESS_KEY="minioadmin"
export MINIO_SECRET_KEY="minioadmin"
./gradlew run
```

## 📁 Структура проекта

```
src/main/kotlin/com/file_micro/
├── Application.kt                    # Главный файл приложения
├── config/
│   └── AppConfig.kt                 # Централизованная конфигурация
├── model/
│   └── ErrorModels.kt               # Модели ошибок
├── service/
│   └── GreetingService.kt          # Пример сервиса
├── infrastructure/
│   └── Databases.kt                 # Конфигурация MinIO
├── plugin/
│   ├── ErrorHandling.kt            # Обработка ошибок
│   ├── HealthCheck.kt              # Health check endpoints
│   ├── Logging.kt                  # Настройка логирования
│   ├── Security.kt                 # Безопасность и CORS
│   ├── Serialization.kt            # JSON сериализация
│   ├── Validation.kt               # Валидация данных
│   ├── UserAuthentication.kt      # Аутентификация пользователей
│   └── GracefulShutdown.kt        # Корректное завершение
├── Routing.kt                      # Базовые маршруты
└── Frameworks.kt                   # Настройка фреймворков
```

### Архитектурные слои

- **Controller** - REST API endpoints (готов к реализации)
- **Service** - Бизнес-логика (готов к реализации)
- **Model** - Модели данных (готов к реализации)
- **Infrastructure** - Внешние зависимости (MinIO)
- **Plugin** - Middleware и плагины Ktor
- **Config** - Конфигурация приложения

## 🐳 Docker конфигурация

- **Dockerfile** - многоэтапная сборка с Gradle и OpenJDK
- **docker-compose.yml** - оркестрация сервисов (приложение + MinIO)
- **env.example** - шаблон переменных окружения

## 🔍 Мониторинг и логирование

### Health Checks

Приложение предоставляет три типа health check:

- **`/health`** - общий статус здоровья (проверяет MinIO и приложение)
- **`/health/ready`** - готовность к работе (проверяет MinIO)
- **`/health/live`** - проверка живости (только приложение)

### Логирование

- Структурированные логи в JSON формате
- Корреляционные ID для трассировки запросов
- Настраиваемые уровни логирования
- Логирование всех HTTP запросов

### Безопасность

- Security headers (HSTS, XSS Protection, Content Type Options)
- CORS настройки
- Валидация входных данных
- Graceful shutdown для корректного завершения
- Okta интеграция для аутентификации

## 🚀 Развертывание

### Production настройки

1. Скопируйте `env.example` в `.env`
2. Настройте production переменные:
```bash
ENVIRONMENT=production
LOG_LEVEL=WARN
CORS_ORIGINS=https://yourdomain.com
MINIO_ENDPOINT=https://your-minio-server.com
```

3. Запустите с Docker:
```bash
docker-compose up -d
```

### Масштабирование

Для горизонтального масштабирования:

1. Используйте внешний MinIO кластер
2. Настройте load balancer
3. Используйте shared session storage (Redis)
4. Настройте мониторинг (Prometheus + Grafana)

## 📚 Полезные ссылки

- [Ktor Documentation](https://ktor.io/docs/home.html)
- [Ktor GitHub](https://github.com/ktorio/ktor)
- [MinIO Documentation](https://docs.min.io/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Kotlin Serialization](https://github.com/Kotlin/kotlinx.serialization)

## 🤝 Вклад в проект

1. Fork репозиторий
2. Создайте feature branch
3. Внесите изменения
4. Добавьте тесты
5. Создайте Pull Request

## 📄 Лицензия

Этот проект распространяется под лицензией MIT. См. файл `LICENSE` для подробностей.

