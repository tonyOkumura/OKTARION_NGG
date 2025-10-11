# Поддержка заголовка Okta-User-ID

## Обзор

Микросервис теперь поддерживает обязательный заголовок `Okta-User-ID` для всех запросов. Этот заголовок используется для идентификации пользователя и аудита операций.

## Что было реализовано

### 1. Плагин UserAuthentication
- **Файл**: `src/main/kotlin/com/contact_micro/plugin/UserAuthentication.kt`
- **Функция**: Автоматическая валидация и обработка заголовка `Okta-User-ID`
- **Валидация**: Проверяет формат пользовательского ID (UUID, email, или alphanumeric)

### 2. CORS настройки
- **Файл**: `src/main/kotlin/com/contact_micro/plugin/Security.kt`
- **Изменение**: Добавлен `allowHeader("Okta-User-ID")` в CORS конфигурацию

### 3. Интеграция в Application
- **Файл**: `src/main/kotlin/com/contact_micro/Application.kt`
- **Изменение**: Добавлен вызов `configureUserAuthentication()` в pipeline

### 4. Обновленные контроллеры
- **Файл**: `src/main/kotlin/com/contact_micro/controller/CitiesRouting.kt`
- **Изменения**: 
  - Добавлено получение `userId` в каждом маршруте
  - Добавлено логирование с пользователем
  - Добавлен `userId` в ответы API

## CORS и браузерные запросы

### Проблема с preflight запросами

Браузеры автоматически отправляют **OPTIONS preflight запросы** перед основными запросами с кастомными заголовками. Эти запросы не содержат заголовок `Okta-User-ID`, поэтому плагин аутентификации был обновлен для их пропуска.

### Решение

1. **Плагин аутентификации** пропускает OPTIONS запросы
2. **Роутинг** обрабатывает OPTIONS запросы для всех endpoints
3. **CORS настройки** разрешают заголовок `Okta-User-ID`

### Примеры CORS ответов

```bash
# Preflight запрос
curl -X OPTIONS http://localhost:8040/cities/1 \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Okta-User-ID" \
  -H "Origin: http://localhost:3000"

# Ответ сервера
HTTP/1.1 200 OK
Access-Control-Allow-Origin: http://localhost:3000
Access-Control-Allow-Credentials: true
Access-Control-Allow-Methods: DELETE, OPTIONS, PUT
Access-Control-Allow-Headers: Authorization, Content-Type, Okta-User-ID, X-Correlation-ID, X-Request-ID
Access-Control-Max-Age: 86400
```

## Использование

### Валидные форматы Okta-User-ID

**Только UUID формат:**
1. **UUID с дефисами**: `123e4567-e89b-12d3-a456-426614174000`
2. **UUID без дефисов**: `123e4567e89b12d3a456426614174000`

**НЕ принимаются:**
- Email адреса: `user@example.com` ❌
- Простые строки: `user123` ❌
- Смешанные форматы: `user-123` ❌

### Примеры запросов

#### Успешный запрос
```bash
curl -X POST http://localhost:8040/cities \
  -H "Okta-User-ID: 123e4567-e89b-12d3-a456-426614174000" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Moscow",
    "country": "Russia",
    "population": 12000000
  }'
```

#### Запрос без заголовка (ошибка 401)
```bash
curl -X GET http://localhost:8040/cities/1
# Ответ: {"error":"UNAUTHORIZED","message":"Okta-User-ID header is required",...}
```

#### Запрос с невалидным заголовком (ошибка 400)
```bash
curl -X GET http://localhost:8040/cities/1 \
  -H "Okta-User-ID: user123@example.com"
# Ответ: {"error":"BAD_REQUEST","message":"Invalid Okta-User-ID format",...}
```

## API изменения

### Новые поля в ответах

Все операции теперь возвращают дополнительное поле с информацией о пользователе:

```json
{
  "id": "1",
  "createdBy": "123e4567-e89b-12d3-a456-426614174000"
}
```

```json
{
  "message": "City updated successfully",
  "updatedBy": "123e4567-e89b-12d3-a456-426614174000"
}
```

### Логирование

Все операции теперь логируются с информацией о пользователе:
```
User: 123e4567-e89b-12d3-a456-426614174000, CorrelationId: abc123 - Creating new city
User: 123e4567-e89b-12d3-a456-426614174000, CorrelationId: abc123 - City created successfully with ID: 1
```

## Extension функции

### Для контроллеров
```kotlin
// Получить ID пользователя (может быть null)
val userId = call.getUserId()

// Получить обязательный ID пользователя (выбрасывает исключение если null)
val userId = call.requireUserId()

// Логировать с информацией о пользователе
call.logWithUser("info", "Operation completed")
```

## Безопасность

- Заголовок `Okta-User-ID` является **обязательным** для всех запросов
- Валидация происходит на уровне intercept pipeline
- Невалидные запросы отклоняются до достижения контроллеров
- Все операции логируются с привязкой к пользователю

## Тестирование

Создан файл `UserAuthenticationExample.kt` с примерами тестирования различных сценариев использования заголовка.

