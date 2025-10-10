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

## Быстрый запуск

### 1. Запуск всех сервисов
```bash
cd server_side
./start-all.sh
```

### 2. Остановка всех сервисов
```bash
cd server_side
./stop-all.sh
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
| Contact DB | localhost:5432 | PostgreSQL БД |
| Conversation DB | localhost:5434 | PostgreSQL БД |

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
│   └── conversation_micro/ # Conversation микросервис
│       ├── docker-compose.yml
│       └── src/             # Исходный код
├── start-all.sh            # Скрипт запуска всех сервисов
└── stop-all.sh             # Скрипт остановки всех сервисов
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
