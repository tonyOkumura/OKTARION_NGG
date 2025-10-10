# Эталонный Микросервис (Microservice Template)

Эталонный микросервис для управления городами, построенный на Ktor с PostgreSQL базой данных. Этот проект служит шаблоном для создания других микросервисов в инфраструктуре.

## 🚀 Особенности

- **Ktor Framework** - современный фреймворк для Kotlin
- **PostgreSQL** - надежная реляционная база данных
- **Docker** - контейнеризация для простого развертывания
- **REST API** - CRUD операции для городов
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
| **SERVER_PORT** | Порт сервера | 8040 |
| **SERVER_HOST** | Хост сервера | 0.0.0.0 |
| **ENVIRONMENT** | Окружение | development |
| **POSTGRES_URL** | URL базы данных | jdbc:postgresql://postgres:5432/contactdb |
| **POSTGRES_USER** | Пользователь БД | contactuser |
| **POSTGRES_PASSWORD** | Пароль БД | contactpass |
| **DB_MAX_POOL_SIZE** | Размер пула соединений | 10 |
| **LOG_LEVEL** | Уровень логирования | INFO |
| **LOG_CORRELATION_ID** | Включить корреляционные ID | true |
| **CORS_ENABLED** | Включить CORS | true |
| **CORS_ORIGINS** | Разрешенные источники | * |
| **RATE_LIMIT_ENABLED** | Включить rate limiting | true |
| **RATE_LIMIT_REQUESTS** | Лимит запросов | 100 |
| **RATE_LIMIT_WINDOW_MINUTES** | Окно лимита (минуты) | 1 |

## 🔧 Структура ошибок

Все ошибки API возвращаются в едином формате:

### Ошибка валидации:
```json
{
  "error": "VALIDATION_ERROR",
  "message": "Validation failed",
  "timestamp": 1640995200000,
  "path": "/cities",
  "correlationId": "abc123",
  "validationErrors": [
    {
      "field": "name",
      "message": "City name cannot be blank"
    },
    {
      "field": "population",
      "message": "Population cannot be negative"
    }
  ]
}
```

### Общая ошибка:
```json
{
  "error": "INTERNAL_ERROR",
  "message": "Failed to create city: Database connection failed",
  "timestamp": 1640995200000,
  "path": "/cities",
  "correlationId": "abc123"
}
```

## 📡 API Endpoints

### Основные endpoints

| Метод | Путь | Описание | Статус |
|-------|------|----------|--------|
| POST | `/cities` | Создать новый город | ✅ |
| GET | `/cities/{id}` | Получить город по ID | ✅ |
| PUT | `/cities/{id}` | Обновить город | ✅ |
| DELETE | `/cities/{id}` | Удалить город | ✅ |

### Health Check endpoints

| Метод | Путь | Описание | Статус |
|-------|------|----------|--------|
| GET | `/health` | Общий статус здоровья | ✅ |
| GET | `/health/ready` | Готовность к работе | ✅ |
| GET | `/health/live` | Проверка живости | ✅ |

### Примеры запросов

**Создание города:**
```bash
curl -X POST http://localhost:8040/cities \
  -H "Content-Type: application/json" \
  -d '{"name": "Moscow", "country": "Russia", "population": 12615000}'
```

**Получение города:**
```bash
curl http://localhost:8040/cities/1
```

**Обновление города:**
```bash
curl -X PUT http://localhost:8040/cities/1 \
  -H "Content-Type: application/json" \
  -d '{"name": "Moscow", "country": "Russia", "population": 13000000}'
```

**Удаление города:**
```bash
curl -X DELETE http://localhost:8040/cities/1
```

**Проверка здоровья:**
```bash
curl http://localhost:8040/health
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

4. Сервис будет доступен по адресу: http://localhost:8040

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
docker-compose logs -f contact-service
```

**Перезапуск сервиса:**
```bash
docker-compose restart contact-service
```

## 💻 Локальная разработка

### Требования

- Java 17+
- Gradle 8.5+
- PostgreSQL 15+

### Настройка базы данных

1. Установите PostgreSQL
2. Создайте базу данных:
```sql
CREATE DATABASE contactdb;
CREATE USER contactuser WITH PASSWORD 'contactpass';
GRANT ALL PRIVILEGES ON DATABASE contactdb TO contactuser;
```

3. Выполните скрипт инициализации:
```bash
psql -U contactuser -d contactdb -f init.sql
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
export POSTGRES_URL="jdbc:postgresql://localhost:5432/contactdb"
export POSTGRES_USER="contactuser"
export POSTGRES_PASSWORD="contactpass"
./gradlew run
```

## 📁 Структура проекта

```
src/main/kotlin/com/example/
├── Application.kt                    # Главный файл приложения
├── config/
│   └── AppConfig.kt                 # Централизованная конфигурация
├── controller/
│   └── CitiesRouting.kt            # REST API endpoints для городов
├── model/
│   ├── CitySchema.kt               # Модель данных и сервис
│   └── ErrorModels.kt              # Модели ошибок
├── service/
│   └── GreetingService.kt          # Пример сервиса
├── infrastructure/
│   └── Databases.kt                # Конфигурация базы данных
├── plugin/
│   ├── ErrorHandling.kt            # Обработка ошибок
│   ├── HealthCheck.kt              # Health check endpoints
│   ├── Logging.kt                  # Настройка логирования
│   ├── Security.kt                 # Безопасность и CORS
│   ├── Serialization.kt            # JSON сериализация
│   ├── Validation.kt               # Валидация данных
│   └── GracefulShutdown.kt        # Корректное завершение
├── Routing.kt                      # Базовые маршруты
└── Frameworks.kt                   # Настройка фреймворков
```

### Архитектурные слои

- **Controller** - REST API endpoints
- **Service** - Бизнес-логика
- **Model** - Модели данных и сервисы
- **Infrastructure** - Внешние зависимости (БД, кэш)
- **Plugin** - Middleware и плагины Ktor
- **Config** - Конфигурация приложения

## 🐳 Docker конфигурация

- **Dockerfile** - многоэтапная сборка с Gradle и OpenJDK
- **docker-compose.yml** - оркестрация сервисов (приложение + PostgreSQL)
- **init.sql** - скрипт инициализации базы данных
- **.dockerignore** - исключения для Docker сборки
- **env.example** - шаблон переменных окружения

## 🔍 Мониторинг и логирование

### Health Checks

Приложение предоставляет три типа health check:

- **`/health`** - общий статус здоровья (проверяет БД и приложение)
- **`/health/ready`** - готовность к работе (проверяет БД)
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

## 🚀 Развертывание

### Production настройки

1. Скопируйте `env.example` в `.env`
2. Настройте production переменные:
```bash
ENVIRONMENT=production
LOG_LEVEL=WARN
CORS_ORIGINS=https://yourdomain.com
```

3. Запустите с Docker:
```bash
docker-compose up -d
```

### Масштабирование

Для горизонтального масштабирования:

1. Используйте внешнюю БД (не в контейнере)
2. Настройте load balancer
3. Используйте shared session storage (Redis)
4. Настройте мониторинг (Prometheus + Grafana)

## 📚 Полезные ссылки

- [Ktor Documentation](https://ktor.io/docs/home.html)
- [Ktor GitHub](https://github.com/ktorio/ktor)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
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

