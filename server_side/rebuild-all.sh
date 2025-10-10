#!/bin/bash

# Скрипт для пересборки всех микросервисов OKTARION NGG
# Автор: AI Assistant
# Дата: $(date)

set -e

echo "🔨 Пересборка OKTARION NGG микросервисов..."
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
rebuild_microservice() {
    local service_name=$1
    local service_dir=$2
    
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

# Пересборка всех микросервисов
log "Начинаем пересборку всех микросервисов..."

# Пересборка contact_micro
rebuild_microservice "Contact" "$(dirname "$0")/business_micros/contact_micro"

# Пересборка conversation_micro
rebuild_microservice "Conversation" "$(dirname "$0")/business_micros/conversation_micro"

# Пересборка message_micro
rebuild_microservice "Message" "$(dirname "$0")/business_micros/message_micro"

# Пересборка task_micro
rebuild_microservice "Task" "$(dirname "$0")/business_micros/task_micro"

# Пересборка event_micro
rebuild_microservice "Event" "$(dirname "$0")/business_micros/event_micro"

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
echo "• Contact Microservice: http://localhost:8040"
echo "• Conversation Microservice: http://localhost:8042"
echo "• Message Microservice: http://localhost:8044"
echo "• Task Microservice: http://localhost:8046"
echo "• Event Microservice: http://localhost:8048"

echo ""
echo "🔧 Полезные команды:"
echo "==================="
echo "• Просмотр логов: docker logs <container_name>"
echo "• Перезапуск конкретного сервиса: cd business_micros/<service> && docker-compose restart"
echo "• Полная остановка: ./stop-all.sh"

success "Все микросервисы пересобраны и запущены успешно! 🎉"
