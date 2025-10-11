#!/bin/bash

# Консольное приложение для управления OKTARION NGG
# Автор: AI Assistant
# Дата: $(date)

set -e

# Доступные микросервисы
AVAILABLE_SERVICES=("contact" "conversation" "message" "task" "event" "tools")

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

# Функция для очистки экрана
clear_screen() {
    clear
}

# Функция для показа заголовка
show_header() {
    clear_screen
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}                    ${WHITE}OKTARION NGG MANAGER${NC}                    ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}              ${CYAN}Консольное управление микросервисами${NC}              ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Функция для показа главного меню
show_main_menu() {
    show_header
    echo -e "${WHITE}Выберите действие:${NC}"
    echo ""
    echo -e "${GREEN}1.${NC} 🚀 Запустить сервисы"
    echo -e "${RED}2.${NC} 🛑 Остановить сервисы"
    echo -e "${YELLOW}3.${NC} 🔨 Пересобрать сервисы"
    echo -e "${BLUE}4.${NC} 📊 Показать статус сервисов"
    echo -e "${CYAN}5.${NC} 📋 Показать логи сервиса"
    echo -e "${PURPLE}6.${NC} 🔧 Полезные команды"
    echo -e "${RED}7.${NC} 🧹 Очистка системы"
    echo -e "${WHITE}8.${NC} ❌ Выход"
    echo ""
    echo -n -e "${YELLOW}Введите номер действия (1-8): ${NC}"
}

# Функция для выбора сервисов
select_services() {
    local action_name=$1
    local selected_services=()
    
    show_header
    echo -e "${WHITE}$action_name сервисы${NC}"
    echo ""
    echo -e "${CYAN}Доступные сервисы:${NC}"
    echo ""
    
    for i in "${!AVAILABLE_SERVICES[@]}"; do
        local service="${AVAILABLE_SERVICES[$i]}"
        local service_name=""
        
        case $service in
            "contact") service_name="Contact" ;;
            "conversation") service_name="Conversation" ;;
            "message") service_name="Message" ;;
            "task") service_name="Task" ;;
            "event") service_name="Event" ;;
            "tools") service_name="Инструменты разработки" ;;
        esac
        
        echo -e "${GREEN}$((i+1)).${NC} $service_name ($service)"
    done
    
    echo ""
    echo -e "${YELLOW}Варианты выбора:${NC}"
    echo -e "  • Введите номера через пробел (например: 1 3 5)"
    echo -e "  • Введите 'all' для выбора всех сервисов"
    echo -e "  • Введите 'back' для возврата в главное меню"
    echo ""
    echo -n -e "${YELLOW}Выберите сервисы: ${NC}"
    
    read -r input
    
    if [[ "$input" == "back" ]]; then
        return 1
    elif [[ "$input" == "all" ]]; then
        selected_services=("${AVAILABLE_SERVICES[@]}")
    else
        # Парсинг номеров
        for num in $input; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#AVAILABLE_SERVICES[@]}" ]; then
                local index=$((num-1))
                selected_services+=("${AVAILABLE_SERVICES[$index]}")
            else
                error "Неверный номер: $num"
                return 1
            fi
        done
    fi
    
    if [ ${#selected_services[@]} -eq 0 ]; then
        error "Не выбрано ни одного сервиса"
        return 1
    fi
    
    # Сохраняем выбранные сервисы в глобальную переменную
    SELECTED_SERVICES=("${selected_services[@]}")
    
    echo ""
    echo -e "${GREEN}Выбраны сервисы: ${selected_services[*]}${NC}"
    echo ""
    echo -n -e "${YELLOW}Продолжить? (y/n): ${NC}"
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Функция для запуска сервисов
start_services() {
    if select_services "Запуск"; then
        show_header
        echo -e "${GREEN}🚀 Запуск сервисов: ${SELECTED_SERVICES[*]}${NC}"
        echo ""
        
        # Вызов скрипта start-all.sh с выбранными сервисами
        ./start-all.sh "${SELECTED_SERVICES[@]}"
        
        echo ""
        echo -n -e "${YELLOW}Нажмите Enter для продолжения...${NC}"
        read -r
    fi
}

# Функция для остановки сервисов
stop_services() {
    if select_services "Остановка"; then
        show_header
        echo -e "${RED}🛑 Остановка сервисов: ${SELECTED_SERVICES[*]}${NC}"
        echo ""
        
        # Вызов скрипта stop-all.sh с выбранными сервисами
        ./stop-all.sh "${SELECTED_SERVICES[@]}"
        
        echo ""
        echo -n -e "${YELLOW}Нажмите Enter для продолжения...${NC}"
        read -r
    fi
}

# Функция для пересборки сервисов
rebuild_services() {
    # Фильтруем tools из доступных сервисов для пересборки
    local rebuildable_services=()
    for service in "${AVAILABLE_SERVICES[@]}"; do
        if [[ "$service" != "tools" ]]; then
            rebuildable_services+=("$service")
        fi
    done
    
    show_header
    echo -e "${YELLOW}🔨 Пересборка сервисов${NC}"
    echo ""
    echo -e "${CYAN}Доступные сервисы для пересборки:${NC}"
    echo ""
    
    for i in "${!rebuildable_services[@]}"; do
        local service="${rebuildable_services[$i]}"
        local service_name=""
        
        case $service in
            "contact") service_name="Contact" ;;
            "conversation") service_name="Conversation" ;;
            "message") service_name="Message" ;;
            "task") service_name="Task" ;;
            "event") service_name="Event" ;;
        esac
        
        echo -e "${GREEN}$((i+1)).${NC} $service_name ($service)"
    done
    
    echo ""
    echo -e "${YELLOW}Варианты выбора:${NC}"
    echo -e "  • Введите номера через пробел (например: 1 3 5)"
    echo -e "  • Введите 'all' для выбора всех сервисов"
    echo -e "  • Введите 'back' для возврата в главное меню"
    echo ""
    echo -n -e "${YELLOW}Выберите сервисы: ${NC}"
    
    read -r input
    
    if [[ "$input" == "back" ]]; then
        return
    elif [[ "$input" == "all" ]]; then
        SELECTED_SERVICES=("${rebuildable_services[@]}")
    else
        local selected_services=()
        # Парсинг номеров
        for num in $input; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#rebuildable_services[@]}" ]; then
                local index=$((num-1))
                selected_services+=("${rebuildable_services[$index]}")
            else
                error "Неверный номер: $num"
                return
            fi
        done
        SELECTED_SERVICES=("${selected_services[@]}")
    fi
    
    if [ ${#SELECTED_SERVICES[@]} -eq 0 ]; then
        error "Не выбрано ни одного сервиса"
        return
    fi
    
    echo ""
    echo -e "${GREEN}Выбраны сервисы: ${SELECTED_SERVICES[*]}${NC}"
    echo ""
    echo -n -e "${YELLOW}Продолжить? (y/n): ${NC}"
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        show_header
        echo -e "${YELLOW}🔨 Пересборка сервисов: ${SELECTED_SERVICES[*]}${NC}"
        echo ""
        
        # Вызов скрипта rebuild-all.sh с выбранными сервисами
        ./rebuild-all.sh "${SELECTED_SERVICES[@]}"
        
        echo ""
        echo -n -e "${YELLOW}Нажмите Enter для продолжения...${NC}"
        read -r
    fi
}

# Функция для показа статуса сервисов
show_status() {
    show_header
    echo -e "${BLUE}📊 Статус сервисов OKTARION NGG${NC}"
    echo ""
    
    # Проверка статуса Docker
    if ! command -v docker &> /dev/null; then
        error "Docker не установлен"
        echo ""
        echo -n -e "${YELLOW}Нажмите Enter для продолжения...${NC}"
        read -r
        return
    fi
    
    echo -e "${CYAN}Контейнеры в сети oktarion_ngg:${NC}"
    echo ""
    
    # Показать статус всех контейнеров в сети oktarion_ngg
    docker ps --filter "network=oktarion_ngg" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Нет запущенных контейнеров в сети oktarion_ngg"
    
    echo ""
    echo -e "${CYAN}Все контейнеры Docker:${NC}"
    echo ""
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Нет запущенных контейнеров"
    
    echo ""
    echo -e "${CYAN}Использование ресурсов:${NC}"
    echo ""
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" 2>/dev/null || echo "Нет запущенных контейнеров"
    
    echo ""
    echo -n -e "${YELLOW}Нажмите Enter для продолжения...${NC}"
    read -r
}

# Функция для показа логов сервиса
show_logs() {
    show_header
    echo -e "${CYAN}📋 Просмотр логов сервиса${NC}"
    echo ""
    echo -e "${CYAN}Доступные сервисы:${NC}"
    echo ""
    
    for i in "${!AVAILABLE_SERVICES[@]}"; do
        local service="${AVAILABLE_SERVICES[$i]}"
        local service_name=""
        
        case $service in
            "contact") service_name="Contact" ;;
            "conversation") service_name="Conversation" ;;
            "message") service_name="Message" ;;
            "task") service_name="Task" ;;
            "event") service_name="Event" ;;
            "tools") service_name="Инструменты разработки" ;;
        esac
        
        echo -e "${GREEN}$((i+1)).${NC} $service_name ($service)"
    done
    
    echo ""
    echo -e "${YELLOW}Варианты выбора:${NC}"
    echo -e "  • Введите номер сервиса"
    echo -e "  • Введите 'back' для возврата в главное меню"
    echo ""
    echo -n -e "${YELLOW}Выберите сервис: ${NC}"
    
    read -r input
    
    if [[ "$input" == "back" ]]; then
        return
    elif [[ "$input" =~ ^[0-9]+$ ]] && [ "$input" -ge 1 ] && [ "$input" -le "${#AVAILABLE_SERVICES[@]}" ]; then
        local index=$((input-1))
        local service="${AVAILABLE_SERVICES[$index]}"
        local service_name=""
        
        case $service in
            "contact") service_name="Contact" ;;
            "conversation") service_name="Conversation" ;;
            "message") service_name="Message" ;;
            "task") service_name="Task" ;;
            "event") service_name="Event" ;;
            "tools") service_name="Инструменты разработки" ;;
        esac
        
        show_header
        echo -e "${CYAN}📋 Логи сервиса: $service_name${NC}"
        echo ""
        
        # Получение имени контейнера
        local container_name=""
        case $service in
            "contact") container_name="contact_micro" ;;
            "conversation") container_name="conversation_micro" ;;
            "message") container_name="message_micro" ;;
            "task") container_name="task_micro" ;;
            "event") container_name="event_micro" ;;
            "tools") container_name="hoppscotch" ;; # Пример для tools
        esac
        
        # Показать логи
        echo -e "${YELLOW}Последние 50 строк логов:${NC}"
        echo ""
        docker logs --tail 50 "$container_name" 2>/dev/null || echo "Контейнер $container_name не найден или не запущен"
        
        echo ""
        echo -e "${YELLOW}Опции:${NC}"
        echo -e "  • Введите 'f' для следования за логами в реальном времени"
        echo -e "  • Введите 'all' для показа всех логов"
        echo -e "  • Введите 'back' для возврата в главное меню"
        echo ""
        echo -n -e "${YELLOW}Выберите опцию: ${NC}"
        
        read -r log_option
        
        case $log_option in
            "f")
                echo ""
                echo -e "${CYAN}Следование за логами (Ctrl+C для выхода):${NC}"
                docker logs -f "$container_name" 2>/dev/null || echo "Контейнер $container_name не найден или не запущен"
                ;;
            "all")
                echo ""
                echo -e "${CYAN}Все логи:${NC}"
                docker logs "$container_name" 2>/dev/null || echo "Контейнер $container_name не найден или не запущен"
                ;;
            "back")
                return
                ;;
        esac
        
        echo ""
        echo -n -e "${YELLOW}Нажмите Enter для продолжения...${NC}"
        read -r
    else
        error "Неверный номер сервиса"
        echo ""
        echo -n -e "${YELLOW}Нажмите Enter для продолжения...${NC}"
        read -r
    fi
}

# Функция для показа полезных команд
show_useful_commands() {
    show_header
    echo -e "${PURPLE}🔧 Полезные команды${NC}"
    echo ""
    
    echo -e "${CYAN}Управление сервисами:${NC}"
    echo -e "  • Запуск всех сервисов: ${GREEN}./start-all.sh${NC}"
    echo -e "  • Остановка всех сервисов: ${RED}./stop-all.sh${NC}"
    echo -e "  • Пересборка всех сервисов: ${YELLOW}./rebuild-all.sh${NC}"
    echo ""
    echo -e "  • Запуск конкретных сервисов: ${GREEN}./start-all.sh contact event${NC}"
    echo -e "  • Остановка конкретных сервисов: ${RED}./stop-all.sh contact event${NC}"
    echo -e "  • Пересборка конкретных сервисов: ${YELLOW}./rebuild-all.sh contact event${NC}"
    echo ""
    
    echo -e "${CYAN}Docker команды:${NC}"
    echo -e "  • Просмотр всех контейнеров: ${BLUE}docker ps -a${NC}"
    echo -e "  • Просмотр логов контейнера: ${BLUE}docker logs <container_name>${NC}"
    echo -e "  • Следование за логами: ${BLUE}docker logs -f <container_name>${NC}"
    echo -e "  • Подключение к контейнеру: ${BLUE}docker exec -it <container_name> /bin/bash${NC}"
    echo -e "  • Остановка контейнера: ${BLUE}docker stop <container_name>${NC}"
    echo -e "  • Удаление контейнера: ${BLUE}docker rm <container_name>${NC}"
    echo ""
    
    echo -e "${CYAN}База данных:${NC}"
    echo -e "  • Подключение к Contact DB: ${BLUE}docker exec -it contact_postgres psql -U contactuser -d contactdb${NC}"
    echo -e "  • Подключение к Conversation DB: ${BLUE}docker exec -it conversation_postgres psql -U conversationuser -d conversationdb${NC}"
    echo -e "  • Подключение к Message DB: ${BLUE}docker exec -it message_postgres psql -U messageuser -d messagedb${NC}"
    echo -e "  • Подключение к Task DB: ${BLUE}docker exec -it task_postgres psql -U taskuser -d taskdb${NC}"
    echo -e "  • Подключение к Event DB: ${BLUE}docker exec -it event_postgres psql -U eventuser -d eventdb${NC}"
    echo ""
    
    echo -e "${CYAN}Сети Docker:${NC}"
    echo -e "  • Просмотр сетей: ${BLUE}docker network ls${NC}"
    echo -e "  • Удаление сети: ${BLUE}docker network rm <network_name>${NC}"
    echo ""
    
    echo -e "${CYAN}Очистка:${NC}"
    echo -e "  • Удаление неиспользуемых образов: ${BLUE}docker image prune${NC}"
    echo -e "  • Удаление неиспользуемых контейнеров: ${BLUE}docker container prune${NC}"
    echo -e "  • Удаление неиспользуемых сетей: ${BLUE}docker network prune${NC}"
    echo -e "  • Полная очистка: ${BLUE}docker system prune -a${NC}"
    echo ""
    
    echo -n -e "${YELLOW}Нажмите Enter для продолжения...${NC}"
    read -r
}

# Функция для очистки системы
cleanup_system() {
    show_header
    echo -e "${RED}🧹 Очистка системы${NC}"
    echo ""
    echo -e "${CYAN}Доступные типы очистки:${NC}"
    echo ""
    echo -e "${GREEN}1.${NC} 🐳 Контейнеры"
    echo -e "${GREEN}2.${NC} 🖼️  Образы"
    echo -e "${GREEN}3.${NC} 💾 Volumes"
    echo -e "${GREEN}4.${NC} 🌐 Сети"
    echo -e "${GREEN}5.${NC} 🔨 Build кэши"
    echo -e "${RED}6.${NC} 💥 Полная очистка"
    echo -e "${YELLOW}7.${NC} 🔙 Назад"
    echo ""
    echo -n -e "${YELLOW}Выберите тип очистки (1-7): ${NC}"
    
    read -r cleanup_choice
    
    case $cleanup_choice in
        1)
            cleanup_type="containers"
            ;;
        2)
            cleanup_type="images"
            ;;
        3)
            cleanup_type="volumes"
            ;;
        4)
            cleanup_type="networks"
            ;;
        5)
            cleanup_type="builds"
            ;;
        6)
            cleanup_type="all"
            ;;
        7)
            return
            ;;
        *)
            show_header
            error "Неверный выбор. Пожалуйста, выберите число от 1 до 7."
            echo ""
            echo -n -e "${YELLOW}Нажмите Enter для продолжения...${NC}"
            read -r
            return
            ;;
    esac
    
    # Выбор сервисов для очистки
    if [[ "$cleanup_type" != "builds" ]]; then
        show_header
        echo -e "${RED}🧹 Очистка $cleanup_type${NC}"
        echo ""
        echo -e "${CYAN}Доступные сервисы:${NC}"
        echo ""
        
        for i in "${!AVAILABLE_SERVICES[@]}"; do
            local service="${AVAILABLE_SERVICES[$i]}"
            local service_name=""
            
            case $service in
                "contact") service_name="Contact" ;;
                "conversation") service_name="Conversation" ;;
                "message") service_name="Message" ;;
                "task") service_name="Task" ;;
                "event") service_name="Event" ;;
                "tools") service_name="Инструменты разработки" ;;
            esac
            
            echo -e "${GREEN}$((i+1)).${NC} $service_name ($service)"
        done
        
        echo ""
        echo -e "${YELLOW}Варианты выбора:${NC}"
        echo -e "  • Введите номера через пробел (например: 1 3 5)"
        echo -e "  • Введите 'all' для выбора всех сервисов"
        echo -e "  • Введите 'back' для возврата в главное меню"
        echo ""
        echo -n -e "${YELLOW}Выберите сервисы: ${NC}"
        
        read -r input
        
        if [[ "$input" == "back" ]]; then
            return
        elif [[ "$input" == "all" ]]; then
            SELECTED_SERVICES=("${AVAILABLE_SERVICES[@]}")
        else
            local selected_services=()
            # Парсинг номеров
            for num in $input; do
                if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#AVAILABLE_SERVICES[@]}" ]; then
                    local index=$((num-1))
                    selected_services+=("${AVAILABLE_SERVICES[$index]}")
                else
                    error "Неверный номер: $num"
                    echo ""
                    echo -n -e "${YELLOW}Нажмите Enter для продолжения...${NC}"
                    read -r
                    return
                fi
            done
            SELECTED_SERVICES=("${selected_services[@]}")
        fi
        
        if [ ${#SELECTED_SERVICES[@]} -eq 0 ]; then
            error "Не выбрано ни одного сервиса"
            echo ""
            echo -n -e "${YELLOW}Нажмите Enter для продолжения...${NC}"
            read -r
            return
        fi
        
        echo ""
        echo -e "${GREEN}Выбраны сервисы: ${SELECTED_SERVICES[*]}${NC}"
    else
        SELECTED_SERVICES=()
    fi
    
    # Подтверждение действия
    echo ""
    echo -e "${RED}⚠️  ВНИМАНИЕ: Эта операция необратима!${NC}"
    echo ""
    echo -n -e "${YELLOW}Продолжить очистку? (y/n): ${NC}"
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        show_header
        echo -e "${RED}🧹 Выполнение очистки $cleanup_type...${NC}"
        echo ""
        
        # Вызов скрипта cleanup.sh
        if [ ${#SELECTED_SERVICES[@]} -gt 0 ]; then
            ./cleanup.sh "$cleanup_type" "${SELECTED_SERVICES[@]}"
        else
            ./cleanup.sh "$cleanup_type"
        fi
        
        echo ""
        echo -n -e "${YELLOW}Нажмите Enter для продолжения...${NC}"
        read -r
    fi
}

# Главный цикл приложения
main() {
    while true; do
        show_main_menu
        read -r choice
        
        case $choice in
            1)
                start_services
                ;;
            2)
                stop_services
                ;;
            3)
                rebuild_services
                ;;
            4)
                show_status
                ;;
            5)
                show_logs
                ;;
            6)
                show_useful_commands
                ;;
            7)
                cleanup_system
                ;;
            8)
                show_header
                echo -e "${GREEN}👋 До свидания!${NC}"
                echo ""
                echo -e "${CYAN}Спасибо за использование OKTARION NGG Manager!${NC}"
                echo ""
                exit 0
                ;;
            *)
                show_header
                error "Неверный выбор. Пожалуйста, выберите число от 1 до 8."
                echo ""
                echo -n -e "${YELLOW}Нажмите Enter для продолжения...${NC}"
                read -r
                ;;
        esac
    done
}

# Проверка наличия необходимых скриптов
check_scripts() {
    local missing_scripts=()
    
    if [ ! -f "./start-all.sh" ]; then
        missing_scripts+=("start-all.sh")
    fi
    
    if [ ! -f "./stop-all.sh" ]; then
        missing_scripts+=("stop-all.sh")
    fi
    
    if [ ! -f "./rebuild-all.sh" ]; then
        missing_scripts+=("rebuild-all.sh")
    fi
    
    if [ ! -f "./cleanup.sh" ]; then
        missing_scripts+=("cleanup.sh")
    fi
    
    if [ ${#missing_scripts[@]} -gt 0 ]; then
        error "Отсутствуют необходимые скрипты: ${missing_scripts[*]}"
        echo ""
        echo -e "${YELLOW}Убедитесь, что все скрипты находятся в той же директории, что и manager.sh${NC}"
        exit 1
    fi
}

# Проверка прав на выполнение
check_permissions() {
    local scripts=("start-all.sh" "stop-all.sh" "rebuild-all.sh" "cleanup.sh")
    
    for script in "${scripts[@]}"; do
        if [ ! -x "$script" ]; then
            warning "Скрипт $script не имеет прав на выполнение. Устанавливаю права..."
            chmod +x "$script"
        fi
    done
}

# Точка входа
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Проверки
    check_scripts
    check_permissions
    
    # Запуск главного цикла
    main
fi
