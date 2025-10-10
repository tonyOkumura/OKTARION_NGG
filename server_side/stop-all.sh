#!/bin/bash

# Скрипт для остановки всех сервисов OKTARION NGG
# Автор: AI Assistant
# Дата: $(date)

set -e

echo "🛑 Остановка OKTARION NGG серверной части..."
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

# Остановка event microservice
log "Остановка Event микросервиса..."
cd "$(dirname "$0")/business_micros/event_micro"
$COMPOSE_CMD down

if [ $? -eq 0 ]; then
    success "Event микросервис остановлен"
else
    warning "Ошибка при остановке Event микросервиса"
fi

# Остановка task microservice
log "Остановка Task микросервиса..."
cd "../task_micro"
$COMPOSE_CMD down

if [ $? -eq 0 ]; then
    success "Task микросервис остановлен"
else
    warning "Ошибка при остановке Task микросервиса"
fi

# Остановка message microservice
log "Остановка Message микросервиса..."
cd "../message_micro"
$COMPOSE_CMD down

if [ $? -eq 0 ]; then
    success "Message микросервис остановлен"
else
    warning "Ошибка при остановке Message микросервиса"
fi

# Остановка conversation microservice
log "Остановка Conversation микросервиса..."
cd "../conversation_micro"
$COMPOSE_CMD down

if [ $? -eq 0 ]; then
    success "Conversation микросервис остановлен"
else
    warning "Ошибка при остановке Conversation микросервиса"
fi

# Остановка contact microservice
log "Остановка Contact микросервиса..."
cd "../contact_micro"
$COMPOSE_CMD down

if [ $? -eq 0 ]; then
    success "Contact микросервис остановлен"
else
    warning "Ошибка при остановке Contact микросервиса"
fi

# Остановка tools
log "Остановка инструментов разработки..."
cd "../../tools"
$COMPOSE_CMD down

if [ $? -eq 0 ]; then
    success "Инструменты разработки остановлены"
else
    warning "Ошибка при остановке инструментов разработки"
fi

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
