# OKTARION NGG - Серверная часть

## Архитектура сети

Проект использует двухуровневую сетевую архитектуру:

### Общая сеть: `oktarion_ngg`
- Связывает все микросервисы и инструменты разработки
- Позволяет сервисам взаимодействовать друг с другом
- **Создается автоматически** при запуске `./start-all.sh`

### Внутренние сети микросервисов: `oktarion_<service>_net`
- Каждый микросервис имеет свою внутреннюю сеть
- Например: `oktarion_contacts_net` для contact микросервиса, `oktarion_conversations_net` для conversation микросервиса
- Обеспечивает изоляцию компонентов микросервиса
- **Создаются автоматически** при запуске `./start-all.sh`

## 🚀 Быстрый запуск

### Интерактивное управление (Рекомендуется)
```bash
cd server_side
./manager.sh
```

### Командная строка
```bash
cd server_side

# Запуск всех сервисов
./start-all.sh

# Остановка всех сервисов
./stop-all.sh

# Пересборка всех сервисов
./rebuild-all.sh
```

### Прямой доступ к скриптам
```bash
cd server_side/shell

# Прямой запуск скриптов из папки shell
./manager.sh
./start-all.sh
./stop-all.sh
./rebuild-all.sh
```

### Выборочное управление сервисами
```bash
# Запуск конкретных сервисов
./start-all.sh contact event

# Остановка конкретных сервисов
./stop-all.sh contact event

# Пересборка конкретных сервисов
./rebuild-all.sh contact event

# Запуск только инструментов разработки
./start-all.sh tools
```

## Доступные сервисы

После запуска будут доступны:

| Сервис | URL | Описание |
|--------|-----|----------|
| Hoppscotch API Testing | http://localhost:3100 | Тестирование API |
| Hoppscotch Admin | http://localhost:3101 | Админ панель |
| pgAdmin | http://localhost:5050 | Управление БД |
| Portainer | http://localhost:9001 | Управление Docker |
| Dozzle | http://localhost:9999 | Просмотр логов |
| Contact Microservice | http://localhost:8040 | API микросервиса |
| Conversation Microservice | http://localhost:8042 | API микросервиса |
| Message Microservice | http://localhost:8044 | API микросервиса |
| Task Microservice | http://localhost:8046 | API микросервиса |
| Event Microservice | http://localhost:8048 | API микросервиса |
| Contact DB | localhost:5433 | PostgreSQL БД |
| Conversation DB | localhost:5434 | PostgreSQL БД |
| Message DB | localhost:5435 | PostgreSQL БД |
| Task DB | localhost:5436 | PostgreSQL БД |
| Event DB | localhost:5437 | PostgreSQL БД |

## Учетные данные

### pgAdmin
- Email: `admin@admin.com`
- Password: `admin`

### Contact Database
- Host: `contact_postgres` (внутри Docker) или `localhost:5432` (снаружи)
- Database: `contactdb`
- Username: `contactuser`
- Password: `contactpass`

### Conversation Database
- Host: `conversation_postgres` (внутри Docker) или `localhost:5434` (снаружи)
- Database: `conversationdb`
- Username: `conversationuser`
- Password: `conversationpass`

### Message Database
- Host: `message_postgres` (внутри Docker) или `localhost:5435` (снаружи)
- Database: `messagedb`
- Username: `messageuser`
- Password: `messagepass`

### Task Database
- Host: `task_postgres` (внутри Docker) или `localhost:5436` (снаружи)
- Database: `taskdb`
- Username: `taskuser`
- Password: `taskpass`

### Event Database
- Host: `event_postgres` (внутри Docker) или `localhost:5437` (снаружи)
- Database: `eventdb`
- Username: `eventuser`
- Password: `eventpass`

## Структура проекта

```
server_side/
├── tools/                    # Инструменты разработки
│   ├── docker-compose.yml   # Hoppscotch, pgAdmin, Portainer, etc.
│   └── pgadmin/             # Конфигурация pgAdmin
├── business_micros/         # Микросервисы
│   ├── contact_micro/       # Contact микросервис
│   │   ├── docker-compose.yml
│   │   └── src/             # Исходный код
│   ├── conversation_micro/  # Conversation микросервис
│   │   ├── docker-compose.yml
│   │   └── src/             # Исходный код
│   ├── message_micro/      # Message микросервис
│   │   ├── docker-compose.yml
│   │   └── src/             # Исходный код
│   ├── task_micro/         # Task микросервис
│   │   ├── docker-compose.yml
│   │   └── src/             # Исходный код
│   └── event_micro/        # Event микросервис
│       ├── docker-compose.yml
│       └── src/             # Исходный код
├── shell/                   # Основные скрипты управления
│   ├── manager.sh          # Интерактивное консольное приложение
│   ├── start-all.sh        # Скрипт запуска сервисов (с параметрами)
│   ├── stop-all.sh         # Скрипт остановки сервисов (с параметрами)
│   ├── rebuild-all.sh      # Скрипт пересборки сервисов (с параметрами)
│   ├── cleanup.sh          # Скрипт очистки системы
│   └── helpers/            # Вспомогательные файлы
│       ├── demo.sh         # Демонстрация возможностей
│       └── MANAGER_README.md # Подробная документация по управлению
└── README.md               # Основная документация
```

## Полезные команды

### Просмотр статуса контейнеров
```bash
docker ps --filter "network=oktarion_ngg"
```

### Просмотр логов микросервиса
```bash
docker logs contact_microservice
```

### Подключение к базе данных
```bash
docker exec -it contact_postgres psql -U contactuser -d contactdb
```

### Перезапуск конкретного сервиса
```bash
cd business_micros/contact_micro
docker-compose restart contact-service
```

## Разработка

### Добавление нового микросервиса

1. Создайте директорию в `business_micros/`
2. Добавьте `docker-compose.yml` с:
   - Внутренней сетью `oktarion_<service>_net`
   - Подключением к общей сети `oktarion_ngg`
3. Обновите конфигурацию pgAdmin для доступа к новой БД
4. Обновите скрипты запуска/остановки

### Пример конфигурации сети для нового микросервиса:
```yaml
networks:
  oktarion_<service>_net:
    driver: bridge
  oktarion_ngg:
    external: true
```

### Примеры названий сетей:
- `oktarion_contacts_net` - для contact микросервиса
- `oktarion_conversations_net` - для conversation микросервиса  
- `oktarion_messages_net` - для message микросервиса
- `oktarion_tasks_net` - для task микросервиса
- `oktarion_events_net` - для event микросервиса

## 🎮 Интерактивное управление

### Консольное приложение `manager.sh`

Запустите интерактивное консольное приложение для удобного управления всеми сервисами:

```bash
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

### Справка по командам

```bash
cd shell
# Показать справку для любого скрипта
./start-all.sh --help
./stop-all.sh --help
./rebuild-all.sh --help
./cleanup.sh --help
```

## 📚 Документация

- **shell/helpers/MANAGER_README.md** - Подробное руководство по использованию системы управления
- **shell/helpers/demo.sh** - Демонстрация возможностей новых скриптов
- **README.md** - Основная документация проекта

## 🚨 Устранение неполадок

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

---

**Приятной разработки с OKTARION NGG! 🚀**
