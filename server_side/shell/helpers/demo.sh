#!/bin/bash

# Демонстрационный скрипт для OKTARION NGG Manager
# Показывает возможности новых скриптов

echo "🎯 Демонстрация OKTARION NGG Manager"
echo "===================================="
echo ""

echo "📋 Доступные команды:"
echo ""

echo "1. 🚀 Запуск сервисов:"
echo "   ./start-all.sh                    # запустить все"
echo "   ./start-all.sh contact event      # запустить только contact и event"
echo "   ./start-all.sh tools              # запустить только инструменты"
echo "   ./start-all.sh supabase           # запустить только Supabase"
echo "   ./start-all.sh cache              # запустить только Cache"
echo ""

echo "2. 🛑 Остановка сервисов:"
echo "   ./stop-all.sh                     # остановить все"
echo "   ./stop-all.sh contact event       # остановить только contact и event"
echo "   ./stop-all.sh tools               # остановить только инструменты"
echo "   ./stop-all.sh supabase            # остановить только Supabase"
echo "   ./stop-all.sh cache               # остановить только Cache"
echo ""

echo "3. 🔨 Пересборка сервисов:"
echo "   ./rebuild-all.sh                  # пересобрать все"
echo "   ./rebuild-all.sh contact event    # пересобрать только contact и event"
echo ""

echo "4. 🧹 Очистка системы:"
echo "   ./cleanup.sh containers           # удалить все контейнеры"
echo "   ./cleanup.sh images               # удалить все образы"
echo "   ./cleanup.sh volumes              # удалить все volumes"
echo "   ./cleanup.sh networks             # удалить все сети"
echo "   ./cleanup.sh builds               # удалить build кэши"
echo "   ./cleanup.sh all                  # полная очистка"
echo "   ./cleanup.sh containers supabase  # очистить контейнеры Supabase"
echo "   ./cleanup.sh containers cache     # очистить контейнеры Cache"
echo ""

echo "5. 🎮 Интерактивное управление:"
echo "   cd shell && ./manager.sh           # запустить консольное приложение"
echo ""

echo "6. 📖 Справка:"
echo "   cd shell && ./start-all.sh --help"
echo "   cd shell && ./stop-all.sh --help"
echo "   cd shell && ./rebuild-all.sh --help"
echo "   cd shell && ./cleanup.sh --help"
echo ""

echo "🌐 Доступные сервисы:"
echo "• Contact Microservice: http://localhost:8040"
echo "• Conversation Microservice: http://localhost:8042"
echo "• Message Microservice: http://localhost:8044"
echo "• Task Microservice: http://localhost:8046"
echo "• Event Microservice: http://localhost:8048"
echo "• Supabase Studio: http://localhost:54323"
echo "• Supabase API: http://localhost:54321"
echo "• Supabase DB: localhost:54322"
echo "• Redis Cache: localhost:6379"
echo "• Redis Commander: http://localhost:8082"
echo "• Hoppscotch API Testing: http://localhost:3100"
echo "• Hoppscotch Admin: http://localhost:3101"
echo "• pgAdmin: http://localhost:5050"
echo "• Portainer: http://localhost:9001"
echo "• Dozzle (логи): http://localhost:9999"
echo ""

echo "📚 Подробная документация:"
echo "shell/helpers/MANAGER_README.md"
echo "README.md"
echo ""

echo "✨ Готово к использованию!"
