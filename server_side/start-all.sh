#!/bin/bash

# Скрипт для запуска всех сервисов OKTARION NGG
# Автор: AI Assistant
# Дата: $(date)

set -e

echo "🚀 Запуск OKTARION NGG серверной части..."
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

# Создание всех необходимых сетей
log "Проверка и создание необходимых сетей..."

# Общая сеть для всех сервисов
create_network_if_not_exists "oktarion_ngg"

# Внутренние сети микросервисов
create_network_if_not_exists "oktarion_contacts_net"
create_network_if_not_exists "oktarion_conversations_net"

# Переход в директорию tools
log "Запуск инструментов разработки..."
cd "$(dirname "$0")/tools"

# Запуск tools (Hoppscotch, pgAdmin, Portainer, Dozzle, etc.)
log "Запуск сервисов разработки (Hoppscotch, pgAdmin, Portainer, Dozzle)..."
$COMPOSE_CMD up -d

if [ $? -eq 0 ]; then
    success "Инструменты разработки запущены успешно"
else
    error "Ошибка при запуске инструментов разработки"
    exit 1
fi

# Переход в директорию contact_micro
log "Запуск микросервиса Contact..."
cd "../business_micros/contact_micro"

# Запуск contact microservice
log "Запуск Contact микросервиса..."
$COMPOSE_CMD up -d

if [ $? -eq 0 ]; then
    success "Contact микросервис запущен успешно"
else
    error "Ошибка при запуске Contact микросервиса"
    exit 1
fi

# Переход в директорию conversation_micro
log "Запуск микросервиса Conversation..."
cd "../conversation_micro"

# Запуск conversation microservice
log "Запуск Conversation микросервиса..."
$COMPOSE_CMD up -d

if [ $? -eq 0 ]; then
    success "Conversation микросервис запущен успешно"
else
    error "Ошибка при запуске Conversation микросервиса"
    exit 1
fi

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
echo "• Hoppscotch API Testing: http://localhost:3100"
echo "• Hoppscotch Admin: http://localhost:3101"
echo "• pgAdmin: http://localhost:5050 (admin@admin.com / admin)"
echo "• Portainer: http://localhost:9001"
echo "• Dozzle (логи): http://localhost:9999"
echo "• Contact Microservice: http://localhost:8040"
echo "• Conversation Microservice: http://localhost:8042"
echo "• Contact DB (PostgreSQL): localhost:5432"
echo "• Conversation DB (PostgreSQL): localhost:5434"

echo ""
echo "🔧 Полезные команды:"
echo "==================="
echo "• Остановить все: ./stop-all.sh"
echo "• Просмотр логов: docker logs <container_name>"
echo "• Подключение к БД: docker exec -it contact_postgres psql -U contactuser -d contactdb"

success "Все сервисы запущены успешно! 🎉"
