#!/bin/bash

# Скрипт для полной очистки Docker компонентов OKTARION NGG
# Автор: AI Assistant
# Дата: $(date)
# Использование: ./cleanup.sh [тип_очистки] [сервисы...]
# Примеры: 
#   ./cleanup.sh containers              # удалить все контейнеры
#   ./cleanup.sh images                  # удалить все образы
#   ./cleanup.sh volumes                 # удалить все volumes
#   ./cleanup.sh networks                # удалить все сети
#   ./cleanup.sh all                     # полная очистка всего
#   ./cleanup.sh containers contact      # удалить контейнеры contact
#   ./cleanup.sh images contact event    # удалить образы contact и event

set -e

# Доступные типы очистки
CLEANUP_TYPES=("containers" "images" "volumes" "networks" "builds" "all")

# Доступные микросервисы
AVAILABLE_SERVICES=("contact" "conversation" "message" "task" "event" "tools" "supabase" "cache")

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Функции для логирования
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

info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# Функция для показа справки
show_help() {
    echo -e "${PURPLE}🧹 Очистка Docker компонентов OKTARION NGG${NC}"
    echo "=============================================="
    echo ""
    echo "Использование: $0 [тип_очистки] [сервисы...]"
    echo ""
    echo -e "${CYAN}Доступные типы очистки:${NC}"
    for cleanup_type in "${CLEANUP_TYPES[@]}"; do
        echo "  • $cleanup_type"
    done
    echo ""
    echo -e "${CYAN}Доступные сервисы:${NC}"
    for service in "${AVAILABLE_SERVICES[@]}"; do
        echo "  • $service"
    done
    echo ""
    echo -e "${YELLOW}Примеры:${NC}"
    echo "  $0 containers              # удалить все контейнеры"
    echo "  $0 images                  # удалить все образы"
    echo "  $0 volumes                 # удалить все volumes"
    echo "  $0 networks                # удалить все сети"
    echo "  $0 builds                  # удалить все build кэши"
    echo "  $0 all                     # полная очистка всего"
    echo "  $0 containers contact      # удалить контейнеры contact"
    echo "  $0 images contact event    # удалить образы contact и event"
    echo ""
    echo -e "${RED}⚠️  ВНИМАНИЕ: Эти операции необратимы!${NC}"
    echo ""
}

# Проверка аргументов
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
    error "Docker не установлен. Пожалуйста, установите Docker."
    exit 1
fi

# Определение типа очистки
if [ $# -eq 0 ]; then
    error "Не указан тип очистки"
    show_help
    exit 1
fi

CLEANUP_TYPE="$1"
shift

# Проверка типа очистки
if [[ ! " ${CLEANUP_TYPES[*]} " =~ " $CLEANUP_TYPE " ]]; then
    error "Неизвестный тип очистки: $CLEANUP_TYPE"
    echo "Доступные типы: ${CLEANUP_TYPES[*]}"
    exit 1
fi

# Определение какие сервисы очистить
if [ $# -eq 0 ]; then
    # Если сервисы не указаны, очистить все
    SERVICES_TO_CLEANUP=("${AVAILABLE_SERVICES[@]}")
    echo -e "${PURPLE}🧹 Очистка $CLEANUP_TYPE для всех сервисов...${NC}"
else
    SERVICES_TO_CLEANUP=()
    for arg in "$@"; do
        if [[ "$arg" == "all" ]]; then
            SERVICES_TO_CLEANUP=("${AVAILABLE_SERVICES[@]}")
            break
        elif [[ " ${AVAILABLE_SERVICES[*]} " =~ " $arg " ]]; then
            SERVICES_TO_CLEANUP+=("$arg")
        else
            error "Неизвестный сервис: $arg"
            echo "Доступные сервисы: ${AVAILABLE_SERVICES[*]}"
            exit 1
        fi
    done
fi

echo -e "${PURPLE}🧹 Очистка $CLEANUP_TYPE для сервисов: ${SERVICES_TO_CLEANUP[*]}${NC}"
echo "=========================================="

# Функция для получения имени контейнера
get_container_name() {
    local service=$1
    case $service in
        "contact") echo "contact_microservice" ;;
        "conversation") echo "conversation_microservice" ;;
        "message") echo "message_microservice" ;;
        "task") echo "task_microservice" ;;
        "event") echo "event_microservice" ;;
        "tools") echo "hoppscotch" ;; # Пример для tools
        "supabase") echo "supabase-studio" ;; # Основной контейнер Supabase
        "cache") echo "cache_db" ;; # Контейнер Redis
    esac
}

# Функция для получения имени образа
get_image_name() {
    local service=$1
    case $service in
        "contact") echo "contact_micro-contact-service" ;;
        "conversation") echo "conversation_micro-conversation-service" ;;
        "message") echo "message_micro-message-service" ;;
        "task") echo "task_micro-task-service" ;;
        "event") echo "event_micro-event-service" ;;
        "tools") echo "hoppscotch" ;; # Пример для tools
        "supabase") echo "supabase/studio" ;; # Основной образ Supabase
        "cache") echo "redis" ;; # Образ Redis
    esac
}

# Функция для получения имени volume
get_volume_name() {
    local service=$1
    case $service in
        "contact") echo "contact_postgres_data" ;;
        "conversation") echo "conversation_postgres_data" ;;
        "message") echo "message_postgres_data" ;;
        "task") echo "task_postgres_data" ;;
        "event") echo "event_postgres_data" ;;
        "tools") echo "hoppscotch_data" ;; # Пример для tools
        "supabase") echo "supabase_db_data" ;; # Volume для данных Supabase
        "cache") echo "cache_data" ;; # Volume для данных Redis
    esac
}

# Функция для получения имени сети
get_network_name() {
    local service=$1
    case $service in
        "contact") echo "oktarion_contacts_net" ;;
        "conversation") echo "oktarion_conversations_net" ;;
        "message") echo "oktarion_messages_net" ;;
        "task") echo "oktarion_tasks_net" ;;
        "event") echo "oktarion_events_net" ;;
        "tools") echo "oktarion_ngg" ;; # Общая сеть
        "supabase") echo "supabase_default" ;; # Сеть Supabase
        "cache") echo "oktarion_ngg" ;; # Общая сеть
    esac
}

# Функция для очистки контейнеров
cleanup_containers() {
    local services=("$@")
    
    log "Очистка контейнеров..."
    
    for service in "${services[@]}"; do
        local container_name=$(get_container_name "$service")
        local service_name=""
        
        case $service in
            "contact") service_name="Contact" ;;
            "conversation") service_name="Conversation" ;;
            "message") service_name="Message" ;;
            "task") service_name="Task" ;;
            "event") service_name="Event" ;;
            "tools") service_name="Tools" ;;
            "supabase") service_name="Supabase" ;;
            "cache") service_name="Cache" ;;
        esac
        
        log "Остановка и удаление контейнеров $service_name..."
        
        # Остановка и удаление контейнеров по имени
        if docker ps -a --format "{{.Names}}" | grep -q "^${container_name}$"; then
            docker stop "$container_name" 2>/dev/null || true
            docker rm "$container_name" 2>/dev/null || true
            success "Контейнер $container_name удален"
        else
            info "Контейнер $container_name не найден"
        fi
        
        # Удаление контейнеров по паттерну
        local pattern="${service}_microservice"
        if docker ps -a --format "{{.Names}}" | grep -q "$pattern"; then
            docker stop $(docker ps -a -q --filter "name=$pattern") 2>/dev/null || true
            docker rm $(docker ps -a -q --filter "name=$pattern") 2>/dev/null || true
            success "Контейнеры $pattern удалены"
        fi
        
        # Удаление контейнеров БД
        local db_pattern="${service}_postgres"
        if docker ps -a --format "{{.Names}}" | grep -q "$db_pattern"; then
            docker stop $(docker ps -a -q --filter "name=$db_pattern") 2>/dev/null || true
            docker rm $(docker ps -a -q --filter "name=$db_pattern") 2>/dev/null || true
            success "Контейнеры БД $db_pattern удалены"
        fi
    done
    
    success "Очистка контейнеров завершена"
}

# Функция для очистки образов
cleanup_images() {
    local services=("$@")
    
    log "Очистка образов..."
    
    for service in "${services[@]}"; do
        local image_name=$(get_image_name "$service")
        local service_name=""
        
        case $service in
            "contact") service_name="Contact" ;;
            "conversation") service_name="Conversation" ;;
            "message") service_name="Message" ;;
            "task") service_name="Task" ;;
            "event") service_name="Event" ;;
            "tools") service_name="Tools" ;;
            "supabase") service_name="Supabase" ;;
            "cache") service_name="Cache" ;;
        esac
        
        log "Удаление образов $service_name..."
        
        # Удаление образов по имени
        if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "$image_name"; then
            docker rmi $(docker images -q "$image_name") 2>/dev/null || true
            success "Образы $image_name удалены"
        else
            info "Образы $image_name не найдены"
        fi
        
        # Удаление образов по паттерну
        local pattern="${service}_micro"
        if docker images --format "{{.Repository}}" | grep -q "$pattern"; then
            docker rmi $(docker images -q --filter "reference=$pattern*") 2>/dev/null || true
            success "Образы $pattern удалены"
        fi
    done
    
    # Удаление dangling образов
    log "Удаление dangling образов..."
    if docker images -f "dangling=true" -q | grep -q .; then
        docker rmi $(docker images -f "dangling=true" -q) 2>/dev/null || true
        success "Dangling образы удалены"
    else
        info "Dangling образы не найдены"
    fi
    
    success "Очистка образов завершена"
}

# Функция для очистки volumes
cleanup_volumes() {
    local services=("$@")
    
    log "Очистка volumes..."
    
    for service in "${services[@]}"; do
        local volume_name=$(get_volume_name "$service")
        local service_name=""
        
        case $service in
            "contact") service_name="Contact" ;;
            "conversation") service_name="Conversation" ;;
            "message") service_name="Message" ;;
            "task") service_name="Task" ;;
            "event") service_name="Event" ;;
            "tools") service_name="Tools" ;;
            "supabase") service_name="Supabase" ;;
            "cache") service_name="Cache" ;;
        esac
        
        log "Удаление volumes $service_name..."
        
        # Удаление volumes по имени
        if docker volume ls --format "{{.Name}}" | grep -q "^${volume_name}$"; then
            docker volume rm "$volume_name" 2>/dev/null || true
            success "Volume $volume_name удален"
        else
            info "Volume $volume_name не найден"
        fi
        
        # Удаление volumes по паттерну
        local pattern="${service}_"
        if docker volume ls --format "{{.Name}}" | grep -q "$pattern"; then
            docker volume rm $(docker volume ls -q --filter "name=$pattern") 2>/dev/null || true
            success "Volumes $pattern удалены"
        fi
    done
    
    # Удаление неиспользуемых volumes
    log "Удаление неиспользуемых volumes..."
    if docker volume ls -f "dangling=true" -q | grep -q .; then
        docker volume rm $(docker volume ls -f "dangling=true" -q) 2>/dev/null || true
        success "Неиспользуемые volumes удалены"
    else
        info "Неиспользуемые volumes не найдены"
    fi
    
    success "Очистка volumes завершена"
}

# Функция для очистки сетей
cleanup_networks() {
    local services=("$@")
    
    log "Очистка сетей..."
    
    for service in "${services[@]}"; do
        local network_name=$(get_network_name "$service")
        local service_name=""
        
        case $service in
            "contact") service_name="Contact" ;;
            "conversation") service_name="Conversation" ;;
            "message") service_name="Message" ;;
            "task") service_name="Task" ;;
            "event") service_name="Event" ;;
            "tools") service_name="Tools" ;;
            "supabase") service_name="Supabase" ;;
            "cache") service_name="Cache" ;;
        esac
        
        log "Удаление сети $service_name..."
        
        # Удаление сети по имени
        if docker network ls --format "{{.Name}}" | grep -q "^${network_name}$"; then
            docker network rm "$network_name" 2>/dev/null || true
            success "Сеть $network_name удалена"
        else
            info "Сеть $network_name не найдена"
        fi
        
        # Удаление сетей по паттерну
        local pattern="oktarion_${service}"
        if docker network ls --format "{{.Name}}" | grep -q "$pattern"; then
            docker network rm $(docker network ls -q --filter "name=$pattern") 2>/dev/null || true
            success "Сети $pattern удалены"
        fi
    done
    
    # Удаление неиспользуемых сетей
    log "Удаление неиспользуемых сетей..."
    if docker network ls --filter "type=custom" -q | grep -q .; then
        docker network prune -f 2>/dev/null || true
        success "Неиспользуемые сети удалены"
    else
        info "Неиспользуемые сети не найдены"
    fi
    
    success "Очистка сетей завершена"
}

# Функция для очистки build кэшей
cleanup_builds() {
    log "Очистка build кэшей..."
    
    # Удаление build кэша
    docker builder prune -f 2>/dev/null || true
    success "Build кэш удален"
    
    # Удаление всех build кэшей
    docker builder prune -a -f 2>/dev/null || true
    success "Все build кэши удалены"
    
    success "Очистка build кэшей завершена"
}

# Функция для полной очистки
cleanup_all() {
    local services=("$@")
    
    log "Полная очистка системы..."
    
    # Остановка всех контейнеров
    log "Остановка всех контейнеров..."
    docker stop $(docker ps -q) 2>/dev/null || true
    
    # Очистка всех компонентов
    cleanup_containers "${services[@]}"
    cleanup_images "${services[@]}"
    cleanup_volumes "${services[@]}"
    cleanup_networks "${services[@]}"
    cleanup_builds
    
    # Системная очистка
    log "Системная очистка..."
    docker system prune -a -f --volumes 2>/dev/null || true
    success "Системная очистка завершена"
    
    success "Полная очистка завершена"
}

# Выполнение очистки
case $CLEANUP_TYPE in
    "containers")
        cleanup_containers "${SERVICES_TO_CLEANUP[@]}"
        ;;
    "images")
        cleanup_images "${SERVICES_TO_CLEANUP[@]}"
        ;;
    "volumes")
        cleanup_volumes "${SERVICES_TO_CLEANUP[@]}"
        ;;
    "networks")
        cleanup_networks "${SERVICES_TO_CLEANUP[@]}"
        ;;
    "builds")
        cleanup_builds
        ;;
    "all")
        cleanup_all "${SERVICES_TO_CLEANUP[@]}"
        ;;
esac

echo ""
echo -e "${CYAN}📊 Статус системы после очистки:${NC}"
echo "================================"

# Показать оставшиеся контейнеры
echo -e "${YELLOW}Контейнеры:${NC}"
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}" 2>/dev/null || echo "Нет контейнеров"

echo ""
echo -e "${YELLOW}Образы:${NC}"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null || echo "Нет образов"

echo ""
echo -e "${YELLOW}Volumes:${NC}"
docker volume ls --format "table {{.Name}}\t{{.Driver}}" 2>/dev/null || echo "Нет volumes"

echo ""
echo -e "${YELLOW}Сети:${NC}"
docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}" 2>/dev/null || echo "Нет сетей"

echo ""
success "Очистка завершена! 🧹✨"
