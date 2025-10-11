#!/bin/bash

# Скрипт для запуска сервисов OKTARION NGG
# Автор: AI Assistant
# Дата: $(date)
# Использование: ./start-all.sh [микросервисы...]
# Примеры: 
#   ./start-all.sh                    # запустить все
#   ./start-all.sh contact event      # запустить только contact и event
#   ./start-all.sh all                # запустить все микросервисы
#   ./start-all.sh tools              # запустить только инструменты

set -e

# Доступные микросервисы
AVAILABLE_SERVICES=("contact" "conversation" "message" "task" "event" "tools")

# Функция для показа справки
show_help() {
    echo "🚀 Запуск сервисов OKTARION NGG"
    echo "==============================="
    echo ""
    echo "Использование: $0 [микросервисы...]"
    echo ""
    echo "Доступные микросервисы:"
    for service in "${AVAILABLE_SERVICES[@]}"; do
        echo "  • $service"
    done
    echo ""
    echo "Примеры:"
    echo "  $0                    # запустить все"
    echo "  $0 contact event      # запустить только contact и event"
    echo "  $0 all                # запустить все микросервисы"
    echo "  $0 tools              # запустить только инструменты"
    echo ""
}

# Проверка аргументов
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Определение какие сервисы запустить
if [ $# -eq 0 ]; then
    # Если аргументы не переданы, запустить все
    SERVICES_TO_START=("${AVAILABLE_SERVICES[@]}")
    echo "🚀 Запуск всех сервисов OKTARION NGG..."
else
    SERVICES_TO_START=()
    for arg in "$@"; do
        if [[ "$arg" == "all" ]]; then
            SERVICES_TO_START=("${AVAILABLE_SERVICES[@]}")
            break
        elif [[ " ${AVAILABLE_SERVICES[*]} " =~ " $arg " ]]; then
            SERVICES_TO_START+=("$arg")
        else
            echo "❌ Неизвестный сервис: $arg"
            echo "Доступные сервисы: ${AVAILABLE_SERVICES[*]}"
            exit 1
        fi
    done
fi

echo "🚀 Запуск сервисов: ${SERVICES_TO_START[*]}"
echo "=========================================="

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для логирования
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Функция для создания сети если не существует
create_network_if_not_exists() {
    local network_name=$1
    if ! docker network ls | grep -q "$network_name"; then
        log "Создание сети $network_name..."
        docker network create "$network_name"
        success "Сеть $network_name создана"
    else
        success "Сеть $network_name уже существует"
    fi
}

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
    error "Docker не установлен. Пожалуйста, установите Docker."
    exit 1
fi

# Проверка наличия Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    error "Docker Compose не установлен. Пожалуйста, установите Docker Compose."
    exit 1
fi

# Определение команды docker-compose
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

log "Используется команда: $COMPOSE_CMD"

# Создание необходимых сетей
log "Проверка и создание необходимых сетей..."

# Общая сеть для всех сервисов
create_network_if_not_exists "oktarion_ngg"

# Создание внутренних сетей только для запускаемых микросервисов
for service in "${SERVICES_TO_START[@]}"; do
    case $service in
        "contact")
            create_network_if_not_exists "oktarion_contacts_net"
            ;;
        "conversation")
            create_network_if_not_exists "oktarion_conversations_net"
            ;;
        "message")
            create_network_if_not_exists "oktarion_messages_net"
            ;;
        "task")
            create_network_if_not_exists "oktarion_tasks_net"
            ;;
        "event")
            create_network_if_not_exists "oktarion_events_net"
            ;;
    esac
done

# Функция для запуска микросервиса
start_service() {
    local service=$1
    local service_name=""
    local service_dir=""
    
    case $service in
        "contact")
            service_name="Contact"
            service_dir="$(dirname "$0")/../business_micros/contact_micro"
            ;;
        "conversation")
            service_name="Conversation"
            service_dir="$(dirname "$0")/../business_micros/conversation_micro"
            ;;
        "message")
            service_name="Message"
            service_dir="$(dirname "$0")/../business_micros/message_micro"
            ;;
        "task")
            service_name="Task"
            service_dir="$(dirname "$0")/../business_micros/task_micro"
            ;;
        "event")
            service_name="Event"
            service_dir="$(dirname "$0")/../business_micros/event_micro"
            ;;
        "tools")
            service_name="Инструменты разработки"
            service_dir="$(dirname "$0")/../tools"
            ;;
    esac
    
    log "Запуск $service_name..."
    cd "$service_dir"
    $COMPOSE_CMD up -d
    
    if [ $? -eq 0 ]; then
        success "$service_name запущен успешно"
    else
        error "Ошибка при запуске $service_name"
        return 1
    fi
    
    # Возврат в исходную директорию
    cd - > /dev/null
}

# Запуск выбранных сервисов
for service in "${SERVICES_TO_START[@]}"; do
    start_service "$service"
done

# Ожидание готовности сервисов
log "Ожидание готовности сервисов..."
sleep 10

# Проверка статуса контейнеров
log "Проверка статуса контейнеров..."
echo ""
echo "📊 Статус контейнеров:"
echo "====================="

# Показать статус всех контейнеров в сети oktarion_ngg
docker ps --filter "network=oktarion_ngg" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "🌐 Доступные сервисы:"
echo "===================="

# Показать только запущенные сервисы
for service in "${SERVICES_TO_START[@]}"; do
    case $service in
        "tools")
            echo "• Hoppscotch API Testing: http://localhost:3100"
            echo "• Hoppscotch Admin: http://localhost:3101"
            echo "• pgAdmin: http://localhost:5050 (admin@admin.com / admin)"
            echo "• Portainer: http://localhost:9001"
            echo "• Dozzle (логи): http://localhost:9999"
            ;;
        "contact")
            echo "• Contact Microservice: http://localhost:8040"
            echo "• Contact DB (PostgreSQL): localhost:5432"
            ;;
        "conversation")
            echo "• Conversation Microservice: http://localhost:8042"
            echo "• Conversation DB (PostgreSQL): localhost:5434"
            ;;
        "message")
            echo "• Message Microservice: http://localhost:8044"
            echo "• Message DB (PostgreSQL): localhost:5435"
            ;;
        "task")
            echo "• Task Microservice: http://localhost:8046"
            echo "• Task DB (PostgreSQL): localhost:5436"
            ;;
        "event")
            echo "• Event Microservice: http://localhost:8048"
            echo "• Event DB (PostgreSQL): localhost:5440"
            ;;
    esac
done

echo ""
echo "🔧 Полезные команды:"
echo "==================="
echo "• Остановить все: ./stop-all.sh"
echo "• Просмотр логов: docker logs <container_name>"
echo "• Подключение к БД: docker exec -it contact_postgres psql -U contactuser -d contactdb"

success "Все сервисы запущены успешно! 🎉"
