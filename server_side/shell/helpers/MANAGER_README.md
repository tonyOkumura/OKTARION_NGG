# OKTARION NGG Manager - Руководство по использованию

## Обзор

Система управления микросервисами OKTARION NGG была улучшена для более гибкого и удобного управления. Теперь вы можете управлять отдельными сервисами или использовать интерактивное консольное приложение.

## Рекомендуемый порядок запуска

Для оптимальной работы системы рекомендуется следующий порядок запуска:

### 1. Cache (Redis) - Кэш-сервер
```bash
./start-all.sh cache
```
- Запускается первым для обеспечения кэширования
- Независимый сервис, не требует других зависимостей

### 2. Supabase - Identity Provider
```bash
./start-all.sh supabase
```
- Запускается вторым для обеспечения аутентификации
- Независимый сервис, не требует других зависимостей

### 3. Микросервисы - Бизнес-логика
```bash
./start-all.sh contact conversation message task event
```
- Запускаются после Cache и Supabase
- Могут использовать кэш и аутентификацию

### 4. Tools - Инструменты разработки
```bash
./start-all.sh tools
```
- Запускаются последними
- Предоставляют инструменты для разработки и мониторинга

### Полный запуск системы
```bash
./start-all.sh
```
Скрипт автоматически запустит все сервисы в оптимальном порядке.

## Доступные скрипты

### 1. `manager.sh` - Интерактивное консольное приложение ⭐

**Основной инструмент для управления всеми сервисами**

```bash
# Из корневой директории проекта
cd server_side/shell
./manager.sh

# Или напрямую из папки shell
cd shell
./manager.sh
```

**Возможности:**
- 🚀 Запуск сервисов (с выбором конкретных)
- 🛑 Остановка сервисов (с выбором конкретных)
- 🔨 Пересборка сервисов (с выбором конкретных)
- 📊 Просмотр статуса всех сервисов
- 📋 Просмотр логов сервисов
- 🔧 Справочник полезных команд
- 🧹 Очистка системы (контейнеры, образы, volumes, сети, build кэши)
- 🆔 Supabase как Identity Provider

**Интерфейс:**
- Красивый цветной интерфейс
- Интуитивное меню с номерами
- Возможность выбора сервисов через номера или "all"
- Подтверждение действий

### 2. `start-all.sh` - Запуск сервисов

**Использование:**
```bash
# Из корня server_side
./start-all.sh
./start-all.sh contact event
./start-all.sh all
./start-all.sh tools
./start-all.sh supabase
./start-all.sh cache
./start-all.sh --help

# Или напрямую из папки shell
cd shell
./start-all.sh
./start-all.sh contact event
./start-all.sh all
./start-all.sh tools
./start-all.sh supabase
./start-all.sh cache
./start-all.sh --help
```

**Доступные сервисы:**
- `contact` - Contact микросервис
- `conversation` - Conversation микросервис
- `message` - Message микросервис
- `task` - Task микросервис
- `event` - Event микросервис
- `tools` - Инструменты разработки (Hoppscotch, pgAdmin, Portainer, Dozzle)
- `supabase` - Supabase (Identity Provider)
- `cache` - Cache (Redis)

### 3. `stop-all.sh` - Остановка сервисов

**Использование:**
```bash
# Остановить все сервисы
./stop-all.sh

# Остановить конкретные сервисы
./stop-all.sh contact event

# Остановить все микросервисы
./stop-all.sh all

# Остановить только инструменты разработки
./stop-all.sh tools

# Остановить только Supabase
./stop-all.sh supabase

# Остановить только Cache
./stop-all.sh cache

# Показать справку
./stop-all.sh --help
```

### 4. `rebuild-all.sh` - Пересборка сервисов

**Использование:**
```bash
# Пересобрать все микросервисы
./rebuild-all.sh

# Пересобрать конкретные сервисы
./rebuild-all.sh contact event

# Пересобрать все микросервисы
./rebuild-all.sh all

# Показать справку
./rebuild-all.sh --help
```

**Примечание:** Supabase и инструменты разработки не пересобираются, так как используют готовые образы.

**Примечание:** Инструменты разработки (`tools`) не пересобираются, так как они используют готовые образы.

### 5. `cleanup.sh` - Очистка системы

**Использование:**
```bash
# Очистить все контейнеры
./cleanup.sh containers

# Очистить все образы
./cleanup.sh images

# Очистить все volumes
./cleanup.sh volumes

# Очистить все сети
./cleanup.sh networks

# Очистить build кэши
./cleanup.sh builds

# Полная очистка всего
./cleanup.sh all

# Очистить контейнеры конкретных сервисов
./cleanup.sh containers contact event

# Очистить образы конкретных сервисов
./cleanup.sh images contact event

# Очистить Supabase
./cleanup.sh containers supabase
./cleanup.sh volumes supabase

# Очистить Cache
./cleanup.sh containers cache
./cleanup.sh volumes cache

# Показать справку
./cleanup.sh --help
```

**Доступные типы очистки:**
- `containers` - Удаление контейнеров
- `images` - Удаление образов
- `volumes` - Удаление volumes
- `networks` - Удаление сетей
- `builds` - Удаление build кэшей
- `all` - Полная очистка всего

**⚠️ ВНИМАНИЕ: Эти операции необратимы!**

## Примеры использования

### Быстрый старт
```bash
# Запустить все сервисы
./manager.sh
# Выбрать пункт 1, затем "all"

# Или через командную строку
./start-all.sh
```

### Разработка конкретного микросервиса
```bash
# Запустить только Contact и инструменты разработки
./start-all.sh contact tools

# Запустить Contact с Supabase для аутентификации
./start-all.sh contact supabase

# Пересобрать Contact после изменений
./rebuild-all.sh contact

# Остановить Contact для отладки
./stop-all.sh contact
```

## Supabase (Identity Provider)

Supabase интегрирован в систему как Identity Provider для аутентификации и авторизации.

### Доступные сервисы Supabase:
- **Supabase Studio**: http://localhost:54323 - Веб-интерфейс для управления
- **Supabase API**: http://localhost:54321 - REST API
- **Supabase DB**: localhost:54322 - PostgreSQL база данных

### Управление Supabase:
```bash
# Запустить только Supabase
./start-all.sh supabase

# Остановить Supabase
./stop-all.sh supabase

# Просмотр логов Supabase
docker logs supabase-studio

# Подключение к базе данных Supabase
docker exec -it supabase-db psql -U postgres -d postgres
```

## Cache (Redis)

Redis интегрирован в систему как кэш-сервер для повышения производительности.

### Доступные сервисы Cache:
- **Redis Cache**: localhost:6379 - Основной Redis сервер
- **Redis Commander**: http://localhost:8082 - Веб-интерфейс для управления

### Управление Cache:
```bash
# Запустить только Cache
./start-all.sh cache

# Остановить Cache
./stop-all.sh cache

# Просмотр логов Cache
docker logs cache_db

# Подключение к Redis
docker exec -it cache_db redis-cli -a cachepass
```

### Отладка
```bash
# Просмотр статуса всех сервисов
./manager.sh
# Выбрать пункт 4

# Просмотр логов Contact
./manager.sh
# Выбрать пункт 5, затем Contact

# Или через командную строку
docker logs contact_micro
```

## Порты сервисов

| Сервис | HTTP порт | DB порт |
|--------|-----------|---------|
| Contact | 8040 | 5432 |
| Conversation | 8042 | 5434 |
| Message | 8044 | 5435 |
| Task | 8046 | 5436 |
| Event | 8048 | 5440 |
| Supabase Studio | 54323 | - |
| Supabase API | 54321 | - |
| Supabase DB | - | 54322 |
| Redis Cache | - | 6379 |
| Redis Commander | 8082 | - |
| Hoppscotch API | 3100 | - |
| Hoppscotch Admin | 3101 | - |
| pgAdmin | 5050 | - |
| Portainer | 9001 | - |
| Dozzle | 9999 | - |

## Полезные команды

### Docker команды
```bash
# Просмотр всех контейнеров
docker ps -a

# Просмотр логов
docker logs <container_name>

# Следование за логами
docker logs -f <container_name>

# Подключение к контейнеру
docker exec -it <container_name> /bin/bash

# Статистика ресурсов
docker stats
```

### База данных
```bash
# Подключение к Contact DB
docker exec -it contact_postgres psql -U contactuser -d contactdb

# Подключение к Conversation DB
docker exec -it conversation_postgres psql -U conversationuser -d conversationdb

# Подключение к Message DB
docker exec -it message_postgres psql -U messageuser -d messagedb

# Подключение к Task DB
docker exec -it task_postgres psql -U taskuser -d taskdb

# Подключение к Event DB
docker exec -it event_postgres psql -U eventuser -d eventdb
```

### Очистка
```bash
# Удаление неиспользуемых образов
docker image prune

# Удаление неиспользуемых контейнеров
docker container prune

# Удаление неиспользуемых сетей
docker network prune

# Полная очистка
docker system prune -a
```

## Структура проекта

```
server_side/
├── shell/                   # Основные скрипты управления
│   ├── manager.sh          # Интерактивное консольное приложение
│   ├── start-all.sh        # Скрипт запуска сервисов
│   ├── stop-all.sh         # Скрипт остановки сервисов
│   ├── rebuild-all.sh      # Скрипт пересборки сервисов
│   ├── cleanup.sh          # Скрипт очистки системы
│   └── helpers/            # Вспомогательные файлы
│       ├── demo.sh         # Демонстрация возможностей
│       └── MANAGER_README.md # Подробная документация
├── business_micros/        # Микросервисы
│   ├── contact_micro/
│   ├── conversation_micro/
│   ├── message_micro/
│   ├── task_micro/
│   └── event_micro/
└── tools/                  # Инструменты разработки
```

## Требования

- Docker
- Docker Compose
- Bash shell
- Права на выполнение скриптов

## Устранение неполадок

### Скрипты не выполняются
```bash
chmod +x *.sh
```

### Docker не запускается
```bash
sudo systemctl start docker
```

### Порты заняты
```bash
# Проверить какие процессы используют порты
sudo netstat -tulpn | grep :8040
sudo lsof -i :8040

# Остановить конфликтующие процессы
sudo kill -9 <PID>
```

### Проблемы с сетями Docker
```bash
# Удалить все сети
docker network prune -f

# Пересоздать сети
./start-all.sh
```

## Поддержка

При возникновении проблем:
1. Проверьте логи сервисов через `./manager.sh` → пункт 5
2. Проверьте статус контейнеров через `./manager.sh` → пункт 4
3. Используйте справочник команд через `./manager.sh` → пункт 6
4. Проверьте требования и устранение неполадок выше

---

**Приятной разработки с OKTARION NGG! 🚀**
