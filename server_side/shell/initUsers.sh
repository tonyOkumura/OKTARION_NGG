#!/bin/bash

# Список 100 уникальных имен на английском
NAMES=(
    "alex" "mary" "john" "sarah" "mike" "lisa" "tom" "emma" "david" "anna"
    "chris" "julia" "mark" "sophie" "daniel" "olivia" "james" "grace" "ryan" "mia"
    "sam" "laura" "ben" "kate" "nick" "zoe" "adam" "hannah" "ethan" "ella"
    "noah" "isabella" "liam" "ava" "william" "sophia" "jackson" "emily" "aiden" "madison"
    "lucas" "chloe" "matthew" "natalie" "jacob" "victoria" "anthony" "scarlett" "joseph" "lily"
    "andrew" "julia" "brandon" "haley" "tyler" "brianna" "jason" "kaylee" "justin" "makayla"
    "kevin" "paige" "austin" "savannah" "jordan" "trinity" "cody" "destiny" "dylan" "faith"
    "eric" "autumn" "sean" "skylar" "ian" "piper" "owen" "lillian" "carter" "nora"
    "logan" "violet" "hunter" "stella" "wyatt" "claire" "nathan" "audrey" "grayson" "brooklyn"
    "jonathan" "z oe" "evan" "sadie" "bryan" "leah" "jeremy" "maya" "zachary" "kaylee"
)

# API ключ (всегда один и тот же)
API_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE"

# Пароль для всех пользователей
PASSWORD="123456"

# Базовый URL
BASE_URL="http://localhost:8008"

echo "🚀 Начинаем создание 100 тестовых пользователей..."
echo "=============================================="

SUCCESS_COUNT=0
FAIL_COUNT=0

for i in "${!NAMES[@]}"; do
    NAME=${NAMES[$i]}
    EMAIL="${NAME}@test.com"
    USERNAME="${NAME}_test"
    
    # Показываем прогресс каждые 10 пользователей
    if [ $((i % 10)) -eq 0 ]; then
        echo ""
        echo "📊 ПРОГРЕСС: $((i+1))/100 пользователей"
    fi
    
    echo -n "   #$((i+1)): $NAME... "
    
    # Шаг 1: Пытаемся зарегистрировать пользователя
    REG_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" \
        --request POST \
        --url "${BASE_URL}/auth/v1/signup" \
        --header "apikey: ${API_KEY}" \
        --header 'content-type: application/json' \
        --data "{\"email\": \"${EMAIL}\", \"password\": \"${PASSWORD}\"}")
    
    HTTP_STATUS=$(echo $REG_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    REG_BODY=$(echo $REG_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
    
    ACCESS_TOKEN=""
    
    if [ "$HTTP_STATUS" = "200" ]; then
        ACCESS_TOKEN=$(echo $REG_BODY | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
    else
        # Логин если уже существует
        LOGIN_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" \
            --request POST \
            --url "${BASE_URL}/auth/v1/token?grant_type=password" \
            --header "apikey: ${API_KEY}" \
            --header 'content-type: application/json' \
            --data "{\"email\": \"${EMAIL}\", \"password\": \"${PASSWORD}\"}")
        
        HTTP_STATUS=$(echo $LOGIN_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
        LOGIN_BODY=$(echo $LOGIN_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
        
        if [ "$HTTP_STATUS" = "200" ]; then
            ACCESS_TOKEN=$(echo $LOGIN_BODY | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
        fi
    fi
    
    # Шаг 2: Создаем контакт
    if [ -n "$ACCESS_TOKEN" ]; then
        CONTACT_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" \
            --request POST \
            --url "${BASE_URL}/api/v1/contacts/" \
            --header "Authorization: Bearer ${ACCESS_TOKEN}" \
            --header 'content-type: application/json' \
            --data "{\"username\": \"${USERNAME}\"}")
        
        CONTACT_STATUS=$(echo $CONTACT_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
        
        if [ "$CONTACT_STATUS" = "201" ]; then
            echo "✅"
            ((SUCCESS_COUNT++))
        else
            echo "❌"
            ((FAIL_COUNT++))
        fi
    else
        echo "❌"
        ((FAIL_COUNT++))
    fi
done

echo ""
echo "=============================================="
echo "🎉 РЕЗУЛЬТАТ:"
echo "✅ Успешно создано: $SUCCESS_COUNT пользователей"
echo "❌ Ошибок: $FAIL_COUNT"
echo "⏱️  Время выполнения: ~2-3 минуты"
echo "=============================================="