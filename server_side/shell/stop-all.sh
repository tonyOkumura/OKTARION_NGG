#!/bin/bash

# Скрипт для остановки сервисов OKTARION NGG
# Автор: AI Assistant
# Дата: $(date)
# Использование: ./stop-all.sh [микросервисы...]
# Примеры: 
#   ./stop-all.sh                    # остановить все
#   ./stop-all.sh contact event      # остановить только contact и event
#   ./stop-all.sh all                # остановить все микросервисы
#   ./stop-all.sh tools              # остановить только инструменты

set -e

# Доступные микросервисы
AVAILABLE_SERVICES=("contact" "conversation" "message" "task" "event" "tools")

# Функция для показа справки
show_help() {
    echo "🛑 Остановка сервисов OKTARION NGG"
    echo "=================================="
    echo ""
    echo "Использование: $0 [микросервисы...]"
    echo ""
    echo "Доступные микросервисы:"
    for service in "${AVAILABLE_SERVICES[@]}"; do
        echo "  • $service"
    done
    echo ""
    echo "Примеры:"
    echo "  $0                    # остановить все"
    echo "  $0 contact event      # остановить только contact и event"
    echo "  $0 all                # остановить все микросервисы"
    echo "  $0 tools              # остановить только инструменты"
    echo ""
}

# Проверка аргументов
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Определение какие сервисы остановить
if [ $# -eq 0 ]; then
    # Если аргументы не переданы, остановить все
    SERVICES_TO_STOP=("${AVAILABLE_SERVICES[@]}")
    echo "🛑 Остановка всех сервисов OKTARION NGG..."
else
    SERVICES_TO_STOP=()
    for arg in "$@"; do
        if [[ "$arg" == "all" ]]; then
            SERVICES_TO_STOP=("${AVAILABLE_SERVICES[@]}")
            break
        elif [[ " ${AVAILABLE_SERVICES[*]} " =~ " $arg " ]]; then
            SERVICES_TO_STOP+=("$arg")
        else
            echo "❌ Неизвестный сервис: $arg"
            echo "Доступные сервисы: ${AVAILABLE_SERVICES[*]}"
            exit 1
        fi
    done
fi

echo "🛑 Остановка сервисов: ${SERVICES_TO_STOP[*]}"
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

# Определение команды docker-compose
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

log "Используется команда: $COMPOSE_CMD"

# Функция для остановки микросервиса
stop_service() {
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
    
    log "Остановка $service_name..."
    cd "$service_dir"
    $COMPOSE_CMD down
    
    if [ $? -eq 0 ]; then
        success "$service_name остановлен"
    else
        warning "Ошибка при остановке $service_name"
    fi
    
    # Возврат в корневую директорию
    cd - > /dev/null
}

# Остановка выбранных сервисов
for service in "${SERVICES_TO_STOP[@]}"; do
    stop_service "$service"
done

# Опционально: удаление сетей (раскомментируйте если нужно)
# log "Удаление внутренних сетей микросервисов..."
# docker network rm oktarion_events_net oktarion_tasks_net oktarion_messages_net oktarion_conversations_net oktarion_contacts_net
# success "Внутренние сети микросервисов удалены"
# 
# log "Удаление общей сети oktarion_ngg..."
# docker network rm oktarion_ngg
# success "Общая сеть oktarion_ngg удалена"

echo ""
echo "📊 Статус контейнеров:"
echo "====================="
docker ps --filter "network=oktarion_ngg" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || echo "Нет запущенных контейнеров в сети oktarion_ngg"

success "Все сервисы остановлены! ✅"
