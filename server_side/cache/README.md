# Cache (Redis) Configuration

## Обзор

Redis кэш-сервер для системы OKTARION NGG с настраиваемой конфигурацией через переменные окружения.

## Конфигурация

Все настройки Redis управляются через файл `.env` в этой папке.

### Основные настройки

| Переменная | Значение по умолчанию | Описание |
|------------|----------------------|----------|
| `REDIS_PASSWORD` | `cachepass` | Пароль для доступа к Redis |
| `REDIS_PORT` | `6379` | Порт для подключения к Redis |
| `REDIS_MAX_MEMORY` | `256mb` | Максимальный объем памяти |
| `REDIS_MAX_MEMORY_POLICY` | `allkeys-lru` | Политика освобождения памяти |

### Настройки персистентности

| Переменная | Значение по умолчанию | Описание |
|------------|----------------------|----------|
| `REDIS_SAVE_900_1` | `900 1` | Сохранение каждые 900 сек при 1 изменении |
| `REDIS_SAVE_300_10` | `300 10` | Сохранение каждые 300 сек при 10 изменениях |
| `REDIS_SAVE_60_10000` | `60 10000` | Сохранение каждые 60 сек при 10000 изменениях |
| `REDIS_APPEND_ONLY` | `yes` | Включить AOF (Append Only File) |
| `REDIS_APPEND_FSYNC` | `everysec` | Частота синхронизации AOF |

### Настройки производительности

| Переменная | Значение по умолчанию | Описание |
|------------|----------------------|----------|
| `REDIS_TCP_KEEPALIVE` | `300` | Интервал keepalive в секундах |
| `REDIS_TIMEOUT` | `0` | Таймаут клиентских соединений |
| `REDIS_LOG_LEVEL` | `notice` | Уровень логирования |

### Настройки кэша

| Переменная | Значение по умолчанию | Описание |
|------------|----------------------|----------|
| `CACHE_DEFAULT_TTL` | `3600` | Время жизни кэша по умолчанию (сек) |
| `CACHE_MAX_KEYS` | `10000` | Максимальное количество ключей |
| `CACHE_SESSION_TTL` | `86400` | Время жизни сессий (сек) |

## Использование

### Запуск
```bash
# Из корневой директории проекта
cd server_side/shell
./start-all.sh cache

# Или напрямую
cd server_side/cache
docker compose up -d
```

### Подключение к Redis
```bash
# Подключение через Docker
docker exec -it cache_db redis-cli -a cachepass

# Подключение с хоста
redis-cli -h localhost -p 6379 -a cachepass
```

### Проверка конфигурации
```bash
# Просмотр всех настроек
docker exec cache_db redis-cli -a cachepass CONFIG GET "*"

# Просмотр конкретной настройки
docker exec cache_db redis-cli -a cachepass CONFIG GET maxmemory
```

## Мониторинг

### Redis Commander
- **URL**: http://localhost:8082
- **Описание**: Веб-интерфейс для управления Redis

### Полезные команды
```bash
# Проверка статуса
docker exec cache_db redis-cli -a cachepass ping

# Информация о сервере
docker exec cache_db redis-cli -a cachepass INFO server

# Статистика памяти
docker exec cache_db redis-cli -a cachepass INFO memory

# Статистика персистентности
docker exec cache_db redis-cli -a cachepass INFO persistence
```

## Изменение конфигурации

1. Отредактируйте файл `.env`
2. Остановите сервис: `./stop-all.sh cache`
3. Запустите сервис: `./start-all.sh cache`

## Примеры использования

### Базовые операции
```bash
# Установка значения
redis-cli -a cachepass SET "user:123" "John Doe"

# Получение значения
redis-cli -a cachepass GET "user:123"

# Установка с TTL
redis-cli -a cachepass SETEX "session:abc" 3600 "active"

# Проверка существования
redis-cli -a cachepass EXISTS "user:123"
```

### Работа с хэшами
```bash
# Создание хэша
redis-cli -a cachepass HSET "user:123" name "John" email "john@example.com"

# Получение всех полей
redis-cli -a cachepass HGETALL "user:123"

# Получение конкретного поля
redis-cli -a cachepass HGET "user:123" name
```

### Работа со списками
```bash
# Добавление в список
redis-cli -a cachepass LPUSH "recent:users" "user:123"

# Получение элементов списка
redis-cli -a cachepass LRANGE "recent:users" 0 -1
```
