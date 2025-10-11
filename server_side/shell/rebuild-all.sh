#!/bin/bash

# Скрипт для пересборки микросервисов OKTARION NGG
# Автор: AI Assistant
# Дата: $(date)
# Использование: ./rebuild-all.sh [микросервисы...]
# Примеры: 
#   ./rebuild-all.sh                    # пересобрать все
#   ./rebuild-all.sh contact event      # пересобрать только contact и event
#   ./rebuild-all.sh all                # пересобрать все микросервисы

set -e

# Доступные микросервисы (без tools, так как они не пересобираются)
AVAILABLE_SERVICES=("contact" "conversation" "message" "task" "event")

# Функция для показа справки
show_help() {
    echo "🔨 Пересборка микросервисов OKTARION NGG"
    echo "========================================"
    echo ""
    echo "Использование: $0 [микросервисы...]"
    echo ""
    echo "Доступные микросервисы:"
    for service in "${AVAILABLE_SERVICES[@]}"; do
        echo "  • $service"
    done
    echo ""
    echo "Примеры:"
    echo "  $0                    # пересобрать все"
    echo "  $0 contact event      # пересобрать только contact и event"
    echo "  $0 all                # пересобрать все микросервисы"
    echo ""
}

# Проверка аргументов
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Определение какие сервисы пересобрать
if [ $# -eq 0 ]; then
    # Если аргументы не переданы, пересобрать все
    SERVICES_TO_REBUILD=("${AVAILABLE_SERVICES[@]}")
    echo "🔨 Пересборка всех микросервисов OKTARION NGG..."
else
    SERVICES_TO_REBUILD=()
    for arg in "$@"; do
        if [[ "$arg" == "all" ]]; then
            SERVICES_TO_REBUILD=("${AVAILABLE_SERVICES[@]}")
            break
        elif [[ " ${AVAILABLE_SERVICES[*]} " =~ " $arg " ]]; then
            SERVICES_TO_REBUILD+=("$arg")
        else
            echo "❌ Неизвестный сервис: $arg"
            echo "Доступные сервисы: ${AVAILABLE_SERVICES[*]}"
            exit 1
        fi
    done
fi

echo "🔨 Пересборка сервисов: ${SERVICES_TO_REBUILD[*]}"
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

# Функция для пересборки микросервиса
rebuild_service() {
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
    esac
    
    log "Пересборка микросервиса $service_name..."
    cd "$service_dir"
    
    # Остановка сервиса
    log "Остановка $service_name..."
    $COMPOSE_CMD down
    
    # Пересборка образа
    log "Пересборка образа $service_name..."
    $COMPOSE_CMD build --no-cache
    
    if [ $? -eq 0 ]; then
        success "Образ $service_name пересобран успешно"
    else
        error "Ошибка при пересборке $service_name"
        return 1
    fi
    
    # Запуск сервиса
    log "Запуск $service_name..."
    $COMPOSE_CMD up -d
    
    if [ $? -eq 0 ]; then
        success "$service_name запущен успешно"
    else
        error "Ошибка при запуске $service_name"
        return 1
    fi
    
    # Возврат в корневую директорию
    cd - > /dev/null
}

# Пересборка выбранных микросервисов
log "Начинаем пересборку выбранных микросервисов..."

for service in "${SERVICES_TO_REBUILD[@]}"; do
    rebuild_service "$service"
done

# Ожидание готовности сервисов
log "Ожидание готовности пересобранных сервисов..."
sleep 15

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

# Показать только пересобранные сервисы
for service in "${SERVICES_TO_REBUILD[@]}"; do
    case $service in
        "contact")
            echo "• Contact Microservice: http://localhost:8040"
            ;;
        "conversation")
            echo "• Conversation Microservice: http://localhost:8042"
            ;;
        "message")
            echo "• Message Microservice: http://localhost:8044"
            ;;
        "task")
            echo "• Task Microservice: http://localhost:8046"
            ;;
        "event")
            echo "• Event Microservice: http://localhost:8048"
            ;;
    esac
done

echo ""
echo "🔧 Полезные команды:"
echo "==================="
echo "• Просмотр логов: docker logs <container_name>"
echo "• Перезапуск конкретного сервиса: cd business_micros/<service> && docker-compose restart"
echo "• Полная остановка: ./stop-all.sh"

success "Все микросервисы пересобраны и запущены успешно! 🎉"
