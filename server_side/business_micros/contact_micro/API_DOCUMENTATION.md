# Contact Microservice API Documentation

## POST /contacts - Создание контакта

### Описание
Создает новый контакт с минимальными данными. Требует только email адрес.

### URL
```
POST /
```

### Заголовки (Headers)
| Заголовок | Тип | Обязательный | Описание |
|-----------|-----|--------------|----------|
| `Okta-User-ID` | String (UUID) | ✅ Да | ID пользователя в формате UUID |
| `Content-Type` | String | ✅ Да | `application/json` |
| `X-Correlation-ID` | String | ❌ Нет | ID для трассировки запроса |

### Тело запроса (Request Body)
```json
{
  "email": "user@example.com"
}
```

#### Описание полей запроса
| Поле | Тип | Обязательный | Описание |
|------|-----|--------------|----------|
| `email` | String | ✅ Да | Email адрес пользователя |

### Формат ответа

#### Успешный ответ (201 Created)
```json
{
  "id": "11111111-1111-1111-1111-111111111111",
  "createdBy": "11111111-1111-1111-1111-111111111111"
}
```

#### Описание полей ответа
| Поле | Тип | Описание |
|------|-----|----------|
| `id` | String (UUID) | ID созданного контакта (из заголовка Okta-User-ID) |
| `createdBy` | String (UUID) | ID пользователя, создавшего контакт |

### Коды ошибок

#### 400 Bad Request
```json
{
  "error": "BAD_REQUEST",
  "message": "Validation failed",
  "timestamp": 1760896518572,
  "path": "/",
  "correlationId": "abc123",
  "validationErrors": [
    {
      "field": "email",
      "message": "Email is required"
    }
  ]
}
```

#### 401 Unauthorized
```json
{
  "error": "UNAUTHORIZED",
  "message": "Okta-User-ID header is required",
  "timestamp": 1760896518572,
  "path": "/",
  "correlationId": "abc123"
}
```

#### 409 Conflict
```json
{
  "error": "CONFLICT",
  "message": "Email already exists: user@example.com",
  "timestamp": 1760896518572,
  "path": "/",
  "correlationId": "abc123"
}
```

### Примеры использования

#### Создание контакта
```bash
curl -X POST "http://localhost:8040/" \
  -H "Content-Type: application/json" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "email": "user@example.com"
  }'
```

### Особенности реализации

#### 🆕 Минимальное создание
- **Только email**: При создании контакта требуется только email адрес
- **Автоматические поля**: Остальные поля заполняются значениями по умолчанию или остаются пустыми
- **Avatar URL**: Автоматически генерируется в формате `{AVATAR_SERVICE_URL}/avatars/{user_id}/download`
- **Значения по умолчанию**: `role = "user"`, `locale = "ru"`, `timezone = "Europe/Moscow"`

---

## PUT /contacts/me - Обновление данных текущего пользователя

### Описание
Обновляет данные контакта для текущего пользователя (того, кто делает запрос). Использует ID из заголовка `Okta-User-ID`. Удобный способ обновить свой профиль без необходимости указывать ID в URL.

### URL
```
PUT /me
```

### Заголовки (Headers)
| Заголовок | Тип | Обязательный | Описание |
|-----------|-----|--------------|----------|
| `Okta-User-ID` | String (UUID) | ✅ Да | ID пользователя в формате UUID |
| `Content-Type` | String | ✅ Да | `application/json` |
| `X-Correlation-ID` | String | ❌ Нет | ID для трассировки запроса |

### Тело запроса (Request Body)
```json
{
  "username": "newusername",
  "firstName": "John",
  "lastName": "Doe",
  "displayName": "John Doe",
  "email": "newemail@example.com",
  "phone": "+1234567890",
  "statusMessage": "Available",
  "role": "admin",
  "department": "IT",
  "rank": "Senior",
  "position": "Developer",
  "company": "Tech Corp",
  "avatarUrl": "http://localhost:8060/avatars/11111111-1111-1111-1111-111111111111/custom.jpg",
  "dateOfBirth": "1990-01-01",
  "locale": "en",
  "timezone": "America/New_York"
}
```

#### Описание полей запроса
| Поле | Тип | Обязательный | Описание |
|------|-----|--------------|----------|
| `username` | String | ❌ Нет | Имя пользователя (3-255 символов, буквы, цифры, подчеркивания и дефисы) |
| `firstName` | String | ❌ Нет | Имя (до 100 символов) |
| `lastName` | String | ❌ Нет | Фамилия (до 100 символов) |
| `displayName` | String | ❌ Нет | Отображаемое имя (до 255 символов) |
| `email` | String | ❌ Нет | Email адрес (валидный формат, до 255 символов) |
| `phone` | String | ❌ Нет | Номер телефона (до 30 символов) |
| `statusMessage` | String | ❌ Нет | Статусное сообщение (до 255 символов) |
| `role` | String | ❌ Нет | Роль (`user`, `admin`, `moderator`) |
| `department` | String | ❌ Нет | Департамент (до 255 символов) |
| `rank` | String | ❌ Нет | Ранг (до 100 символов) |
| `position` | String | ❌ Нет | Должность (до 255 символов) |
| `company` | String | ❌ Нет | Компания (до 255 символов) |
| `avatarUrl` | String | ❌ Нет | URL аватара (валидный URL) |
| `dateOfBirth` | String | ❌ Нет | Дата рождения (YYYY-MM-DD) |
| `locale` | String | ❌ Нет | Локаль (валидный формат) |
| `timezone` | String | ❌ Нет | Часовой пояс (валидный формат) |

### Формат ответа

#### Успешный ответ (200 OK)
```json
{
  "message": "Contact updated successfully",
  "updatedBy": "11111111-1111-1111-1111-111111111111"
}
```

#### Описание полей ответа
| Поле | Тип | Описание |
|------|-----|----------|
| `message` | String | Сообщение об успешном обновлении |
| `updatedBy` | String (UUID) | ID пользователя, обновившего контакт |

### Коды ошибок

#### 400 Bad Request
```json
{
  "error": "BAD_REQUEST",
  "message": "Validation failed",
  "timestamp": 1760896518572,
  "path": "/me",
  "correlationId": "abc123",
  "validationErrors": [
    {
      "field": "email",
      "message": "Invalid email format"
    }
  ]
}
```

#### 401 Unauthorized
```json
{
  "error": "UNAUTHORIZED",
  "message": "Okta-User-ID header is required",
  "timestamp": 1760896518572,
  "path": "/me",
  "correlationId": "abc123"
}
```

#### 404 Not Found
```json
{
  "error": "NOT_FOUND",
  "message": "Contact not found",
  "timestamp": 1760896518572,
  "path": "/me",
  "correlationId": "abc123"
}
```

### Примеры использования

#### 1. Обновление основных полей профиля
```bash
curl -X PUT "http://localhost:8040/me" \
  -H "Content-Type: application/json" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "username": "johndoe",
    "firstName": "John",
    "lastName": "Doe",
    "displayName": "John Doe"
  }'
```

#### 2. Обновление контактной информации
```bash
curl -X PUT "http://localhost:8040/me" \
  -H "Content-Type: application/json" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "email": "new.email@example.com",
    "phone": "+1234567890"
  }'
```

#### 3. Обновление статуса
```bash
curl -X PUT "http://localhost:8040/me" \
  -H "Content-Type: application/json" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "isOnline": true,
    "statusMessage": "Available for meetings"
  }'
```

#### 4. Обновление рабочей информации
```bash
curl -X PUT "http://localhost:8040/me" \
  -H "Content-Type: application/json" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "department": "Engineering",
    "position": "Senior Developer",
    "company": "Tech Corp"
  }'
```

#### 5. Обновление настроек локализации
```bash
curl -X PUT "http://localhost:8040/me" \
  -H "Content-Type: application/json" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "locale": "en",
    "timezone": "America/New_York"
  }'
```

### Особенности реализации

#### 👤 Персональное обновление
- **Автоматическое определение**: Использует ID из заголовка `Okta-User-ID` для поиска контакта
- **Безопасность**: Обновляет только данные текущего пользователя
- **Простота**: Не требует передачи ID в URL
- **Частичное обновление**: Обновляются только переданные поля
- **Валидация**: Все переданные поля проходят валидацию
- **Уникальность**: Проверяется уникальность email, username, phone (исключая текущий контакт)

#### 🔄 Логика работы
1. **Извлечение ID**: Получает ID пользователя из заголовка `Okta-User-ID`
2. **Валидация**: Проверяет все переданные поля
3. **Проверка уникальности**: Проверяет уникальность полей (исключая текущий контакт)
4. **Обновление**: Обновляет только переданные поля
5. **Автоматическое обновление**: Поле `updated_at` обновляется автоматически

---

## PUT /contacts/{id} - Обновление контакта

### Описание
Обновляет существующий контакт. Можно обновить любые поля контакта.

### URL
```
PUT /{id}
```

### Заголовки (Headers)
| Заголовок | Тип | Обязательный | Описание |
|-----------|-----|--------------|----------|
| `Okta-User-ID` | String (UUID) | ✅ Да | ID пользователя в формате UUID |
| `Content-Type` | String | ✅ Да | `application/json` |
| `X-Correlation-ID` | String | ❌ Нет | ID для трассировки запроса |

### Параметры пути (Path Parameters)
| Параметр | Тип | Обязательный | Описание |
|----------|-----|--------------|----------|
| `id` | String (UUID) | ✅ Да | ID контакта для обновления |

### Тело запроса (Request Body)
```json
{
  "username": "newusername",
  "firstName": "John",
  "lastName": "Doe",
  "displayName": "John Doe",
  "email": "newemail@example.com",
  "phone": "+1234567890",
  "statusMessage": "Available",
  "role": "admin",
  "department": "IT",
  "rank": "Senior",
  "position": "Developer",
  "company": "Tech Corp",
  "avatarUrl": "http://localhost:8060/avatars/11111111-1111-1111-1111-111111111111/custom.jpg",
  "dateOfBirth": "1990-01-01",
  "locale": "en",
  "timezone": "America/New_York"
}
```

#### Описание полей запроса
| Поле | Тип | Обязательный | Описание |
|------|-----|--------------|----------|
| `username` | String | ❌ Нет | Имя пользователя (3-255 символов, буквы, цифры, подчеркивания и дефисы) |
| `firstName` | String | ❌ Нет | Имя (до 100 символов) |
| `lastName` | String | ❌ Нет | Фамилия (до 100 символов) |
| `displayName` | String | ❌ Нет | Отображаемое имя (до 255 символов) |
| `email` | String | ❌ Нет | Email адрес (валидный формат, до 255 символов) |
| `phone` | String | ❌ Нет | Номер телефона (до 30 символов) |
| `statusMessage` | String | ❌ Нет | Статусное сообщение (до 255 символов) |
| `role` | String | ❌ Нет | Роль (`user`, `admin`, `moderator`) |
| `department` | String | ❌ Нет | Департамент (до 255 символов) |
| `rank` | String | ❌ Нет | Ранг (до 100 символов) |
| `position` | String | ❌ Нет | Должность (до 255 символов) |
| `company` | String | ❌ Нет | Компания (до 255 символов) |
| `avatarUrl` | String | ❌ Нет | URL аватара (валидный URL) |
| `dateOfBirth` | String | ❌ Нет | Дата рождения (YYYY-MM-DD) |
| `locale` | String | ❌ Нет | Локаль (валидный формат) |
| `timezone` | String | ❌ Нет | Часовой пояс (валидный формат) |

### Формат ответа

#### Успешный ответ (200 OK)
```json
{
  "message": "Contact updated successfully",
  "updatedBy": "11111111-1111-1111-1111-111111111111"
}
```

#### Описание полей ответа
| Поле | Тип | Описание |
|------|-----|----------|
| `message` | String | Сообщение об успешном обновлении |
| `updatedBy` | String (UUID) | ID пользователя, обновившего контакт |

### Коды ошибок

#### 400 Bad Request
```json
{
  "error": "BAD_REQUEST",
  "message": "Validation failed",
  "timestamp": 1760896518572,
  "path": "/11111111-1111-1111-1111-111111111111",
  "correlationId": "abc123",
  "validationErrors": [
    {
      "field": "email",
      "message": "Invalid email format"
    }
  ]
}
```

#### 404 Not Found
```json
{
  "error": "NOT_FOUND",
  "message": "Contact not found",
  "timestamp": 1760896518572,
  "path": "/11111111-1111-1111-1111-111111111111",
  "correlationId": "abc123"
}
```

### Расширенные примеры использования

#### 1. Обновление основных полей профиля
```bash
curl -X PUT "http://localhost:8040/11111111-1111-1111-1111-111111111111" \
  -H "Content-Type: application/json" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "username": "johndoe",
    "firstName": "John",
    "lastName": "Doe",
    "displayName": "John Doe",
    "email": "john.doe@example.com"
  }'
```

#### 2. Обновление только роли
```bash
curl -X PUT "http://localhost:8040/11111111-1111-1111-1111-111111111111" \
  -H "Content-Type: application/json" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "role": "admin"
  }'
```

#### 3. Обновление контактной информации
```bash
curl -X PUT "http://localhost:8040/11111111-1111-1111-1111-111111111111" \
  -H "Content-Type: application/json" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "phone": "+1234567890",
    "email": "new.email@example.com"
  }'
```

#### 4. Обновление рабочей информации
```bash
curl -X PUT "http://localhost:8040/11111111-1111-1111-1111-111111111111" \
  -H "Content-Type: application/json" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "department": "Engineering",
    "rank": "Senior",
    "position": "Lead Developer",
    "company": "Tech Corp"
  }'
```

#### 5. Обновление статуса и настроек
```bash
curl -X PUT "http://localhost:8040/11111111-1111-1111-1111-111111111111" \
  -H "Content-Type: application/json" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "isOnline": true,
    "statusMessage": "Available for meetings",
    "locale": "en",
    "timezone": "America/New_York"
  }'
```

#### 6. Обновление аватара
```bash
curl -X PUT "http://localhost:8040/11111111-1111-1111-1111-111111111111" \
  -H "Content-Type: application/json" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "avatarUrl": "http://localhost:8060/avatars/11111111-1111-1111-1111-111111111111/custom-avatar.jpg"
  }'
```

#### 7. Обновление личной информации
```bash
curl -X PUT "http://localhost:8040/11111111-1111-1111-1111-111111111111" \
  -H "Content-Type: application/json" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "dateOfBirth": "1990-01-01"
  }'
```

#### 8. Полное обновление профиля
```bash
curl -X PUT "http://localhost:8040/11111111-1111-1111-1111-111111111111" \
  -H "Content-Type: application/json" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111" \
  -d '{
    "username": "johndoe",
    "firstName": "John",
    "lastName": "Doe",
    "displayName": "John Doe",
    "email": "john.doe@example.com",
    "phone": "+1234567890",
    "isOnline": true,
    "statusMessage": "Available",
    "role": "user",
    "department": "IT",
    "rank": "Senior",
    "position": "Developer",
    "company": "Tech Corp",
    "avatarUrl": "http://localhost:8060/avatars/11111111-1111-1111-1111-111111111111/download",
    "dateOfBirth": "1990-01-01",
    "locale": "ru",
    "timezone": "Europe/Moscow"
  }'
```

### Детальное описание полей

#### 👤 Основные поля профиля
| Поле | Тип | Валидация | Описание |
|------|-----|-----------|----------|
| `username` | String | 3-255 символов, буквы, цифры, подчеркивания и дефисы | Уникальное имя пользователя |
| `firstName` | String | До 100 символов | Имя |
| `lastName` | String | До 100 символов | Фамилия |
| `displayName` | String | До 255 символов | Отображаемое имя (может отличаться от firstName + lastName) |

#### 📧 Контактная информация
| Поле | Тип | Валидация | Описание |
|------|-----|-----------|----------|
| `email` | String | Валидный email формат, до 255 символов | Email адрес (уникальный) |
| `phone` | String | До 30 символов | Номер телефона (уникальный) |

#### 🏢 Рабочая информация
| Поле | Тип | Валидация | Описание |
|------|-----|-----------|----------|
| `role` | String | `user`, `admin`, `moderator` | Роль в системе |
| `department` | String | До 255 символов | Департамент |
| `rank` | String | До 100 символов | Ранг/уровень |
| `position` | String | До 255 символов | Должность |
| `company` | String | До 255 символов | Компания |

#### 📱 Статус и настройки
| Поле | Тип | Валидация | Описание |
|------|-----|-----------|----------|
| `isOnline` | Boolean | true/false | Статус онлайн |
| `statusMessage` | String | До 255 символов | Статусное сообщение |
| `locale` | String | Валидный формат локали | Локаль (ru, en, etc.) |
| `timezone` | String | Валидный часовой пояс | Часовой пояс |

#### 🖼️ Дополнительные поля
| Поле | Тип | Валидация | Описание |
|------|-----|-----------|----------|
| `avatarUrl` | String | Валидный URL | URL аватара |
| `dateOfBirth` | String | YYYY-MM-DD формат | Дата рождения |

### Логика обновления

#### 🔄 Алгоритм обновления
1. **Валидация**: Проверяются все переданные поля на соответствие требованиям
2. **Проверка уникальности**: Проверяется уникальность email, username, phone (исключая текущий контакт)
3. **Динамическое обновление**: Обновляются только переданные поля
4. **Автоматическое обновление**: Поле `updated_at` обновляется автоматически

#### ✅ Валидация полей
- **Обязательные проверки**: Все переданные поля проходят валидацию
- **Уникальность**: Email, username, phone должны быть уникальными
- **Формат данных**: Проверяется корректность форматов (email, дата, URL)
- **Длина полей**: Проверяется соответствие ограничениям по длине

#### 🚫 Обработка ошибок
- **400 Bad Request**: Ошибки валидации с детальным описанием
- **404 Not Found**: Контакт не найден
- **409 Conflict**: Нарушение уникальности полей
- **500 Internal Server Error**: Внутренние ошибки сервера

### Особенности реализации

#### 🔄 Частичное обновление
- **Только переданные поля**: Обновляются только те поля, которые переданы в запросе
- **Валидация**: Все переданные поля проходят валидацию
- **Уникальность**: Проверяется уникальность email, username, phone (исключая текущий контакт)
- **Автоматическое обновление**: Поле `updated_at` обновляется автоматически

---

## GET /contacts/me - Получение данных текущего пользователя

### Описание
Возвращает данные контакта для текущего пользователя (того, кто делает запрос). Использует ID из заголовка `Okta-User-ID`.

### URL
```
GET /me
```

### Заголовки (Headers)
| Заголовок | Тип | Обязательный | Описание |
|-----------|-----|--------------|----------|
| `Okta-User-ID` | String (UUID) | ✅ Да | ID пользователя в формате UUID |
| `X-Correlation-ID` | String | ❌ Нет | ID для трассировки запроса |

### Формат ответа

#### Успешный ответ (200 OK)
```json
{
  "id": "11111111-1111-1111-1111-111111111111",
  "username": "johndoe",
  "firstName": "John",
  "lastName": "Doe",
  "displayName": "John Doe",
  "email": "john.doe@example.com",
  "phone": "+1234567890",
  "isOnline": true,
  "lastSeenAt": "2025-10-18T15:30:00.000000",
  "statusMessage": "Available",
  "role": "user",
  "department": "IT",
  "rank": "Senior",
  "position": "Developer",
  "company": "Tech Corp",
  "avatarUrl": "http://localhost:8060/avatars/11111111-1111-1111-1111-111111111111/download",
  "dateOfBirth": "1990-01-01",
  "locale": "ru",
  "timezone": "Europe/Moscow",
  "createdAt": "2025-10-18T13:29:20.728567",
  "updatedAt": "2025-10-18T15:30:00.000000"
}
```

### Коды ошибок

#### 401 Unauthorized
```json
{
  "error": "UNAUTHORIZED",
  "message": "Okta-User-ID header is required",
  "timestamp": 1760896518572,
  "path": "/me",
  "correlationId": "abc123"
}
```

#### 404 Not Found
```json
{
  "error": "NOT_FOUND",
  "message": "Contact not found",
  "timestamp": 1760896518572,
  "path": "/me",
  "correlationId": "abc123"
}
```

### Примеры использования

#### Получение данных текущего пользователя
```bash
curl -X GET "http://localhost:8040/me" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111"
```

### Особенности реализации

#### 👤 Персональные данные
- **Автоматическое определение**: Использует ID из заголовка `Okta-User-ID` для поиска контакта
- **Безопасность**: Возвращает только данные текущего пользователя
- **Простота**: Не требует передачи ID в URL

---

## GET /contacts - Получение списка контактов

### Описание
Основной эндпоинт для получения списка контактов с поддержкой поиска, фильтрации, сортировки и пагинации. Также поддерживает получение контактов по конкретным ID.

### URL
```
GET /
```

### Заголовки (Headers)
| Заголовок | Тип | Обязательный | Описание |
|-----------|-----|--------------|----------|
| `Okta-User-ID` | String (UUID) | ✅ Да | ID пользователя в формате UUID |
| `Content-Type` | String | ❌ Нет | `application/json` (для запросов с телом) |
| `X-Correlation-ID` | String | ❌ Нет | ID для трассировки запроса |

### Параметры запроса (Query Parameters)

#### 🔍 Поиск и пагинация
| Параметр | Тип | Обязательный | Описание | Пример |
|----------|-----|--------------|----------|--------|
| `search` | String | ❌ Нет | Глобальный поиск по текстовым полям | `?search=admin` |
| `cursor` | String (ISO timestamp) | ❌ Нет | Курсор для пагинации (время создания последнего контакта) | `?cursor=2025-10-18T13:29:20.728567` |
| `limit` | Integer | ❌ Нет | Количество контактов на страницу (1-100) | `?limit=20` |

#### 🎯 Фильтрация
| Параметр | Тип | Описание | Пример |
|----------|-----|----------|--------|
| `role` | String | Фильтр по роли (точное совпадение) | `?role=admin` |
| `department` | String | Фильтр по департаменту (частичное совпадение) | `?department=IT` |
| `company` | String | Фильтр по компании (частичное совпадение) | `?company=Microsoft` |
| `is_online` | Boolean | Фильтр по статусу онлайн | `?is_online=true` |
| `locale` | String | Фильтр по локали (точное совпадение) | `?locale=ru` |
| `timezone` | String | Фильтр по часовому поясу (точное совпадение) | `?timezone=Europe/Moscow` |
| `username` | String | Фильтр по имени пользователя (частичное совпадение) | `?username=john` |
| `email` | String | Фильтр по email (частичное совпадение) | `?email=company.com` |
| `phone` | String | Фильтр по телефону (частичное совпадение) | `?phone=123` |
| `firstName` | String | Фильтр по имени (частичное совпадение) | `?firstName=John` |
| `lastName` | String | Фильтр по фамилии (частичное совпадение) | `?lastName=Smith` |
| `displayName` | String | Фильтр по отображаемому имени (частичное совпадение) | `?displayName=John` |
| `statusMessage` | String | Фильтр по статусному сообщению (частичное совпадение) | `?statusMessage=away` |
| `rank` | String | Фильтр по рангу (частичное совпадение) | `?rank=senior` |
| `position` | String | Фильтр по должности (частичное совпадение) | `?position=developer` |

#### 📊 Сортировка
| Параметр | Тип | Описание | Возможные значения |
|----------|-----|----------|-------------------|
| `sortBy` | String | Поле для сортировки | `created_at`, `updated_at`, `username`, `firstName`, `lastName`, `email`, `role`, `department`, `company` |
| `sortOrder` | String | Порядок сортировки | `ASC` (по возрастанию), `DESC` (по убыванию) |

#### 🆔 Получение по конкретным ID
| Параметр | Тип | Описание | Пример |
|----------|-----|----------|--------|
| `ids` | String (CSV) | Список UUID контактов через запятую (максимум 100) | `?ids=11111111-1111-1111-1111-111111111111,22222222-2222-2222-2222-222222222222` |

### Формат ответа

#### Успешный ответ (200 OK)
```json
{
  "contacts": [
    {
      "id": "11111111-1111-1111-1111-111111111111",
      "username": "admin1",
      "firstName": "Admin",
      "lastName": "User",
      "displayName": null,
      "email": "admin@company.com",
      "phone": null,
      "isOnline": false,
      "lastSeenAt": null,
      "statusMessage": null,
      "role": "admin",
      "department": "IT",
      "rank": null,
      "position": null,
      "company": null,
      "avatarUrl": "http://localhost:8060/avatars/11111111-1111-1111-1111-111111111111/download",
      "dateOfBirth": null,
      "locale": "ru",
      "timezone": "Europe/Moscow",
      "createdAt": "2025-10-18T13:29:20.728567",
      "updatedAt": "2025-10-18T13:29:20.728567"
    }
  ],
  "hasMore": true,
  "nextCursor": "2025-10-18T13:29:20.728567",
  "totalCount": null
}
```

#### Описание полей ответа
| Поле | Тип | Описание |
|------|-----|----------|
| `contacts` | Array | Массив объектов контактов |
| `hasMore` | Boolean | Есть ли еще контакты для загрузки |
| `nextCursor` | String | Курсор для следующей страницы (ISO timestamp) |
| `totalCount` | Integer\|null | Общее количество контактов (только для запросов по ID) |

#### Описание полей контакта
| Поле | Тип | Описание |
|------|-----|----------|
| `id` | String (UUID) | Уникальный идентификатор контакта |
| `username` | String | Имя пользователя |
| `firstName` | String\|null | Имя |
| `lastName` | String\|null | Фамилия |
| `displayName` | String\|null | Отображаемое имя |
| `email` | String\|null | Email адрес |
| `phone` | String\|null | Номер телефона |
| `isOnline` | Boolean | Статус онлайн |
| `lastSeenAt` | String\|null | Время последней активности (ISO timestamp) |
| `statusMessage` | String\|null | Статусное сообщение |
| `role` | String | Роль пользователя (`user`, `admin`, `moderator`) |
| `department` | String\|null | Департамент |
| `rank` | String\|null | Ранг |
| `position` | String\|null | Должность |
| `company` | String\|null | Компания |
| `avatarUrl` | String\|null | URL аватара пользователя (автоматически генерируется при создании) |
| `dateOfBirth` | String\|null | Дата рождения (ISO date) |
| `locale` | String | Локаль (по умолчанию `ru`) |
| `timezone` | String | Часовой пояс (по умолчанию `Europe/Moscow`) |
| `createdAt` | String | Время создания (ISO timestamp) |
| `updatedAt` | String | Время последнего обновления (ISO timestamp) |

### Коды ошибок

#### 400 Bad Request
```json
{
  "error": "BAD_REQUEST",
  "message": "IDs list cannot be empty",
  "timestamp": 1760896518572,
  "path": "/",
  "correlationId": "abc123"
}
```

#### 401 Unauthorized
```json
{
  "error": "UNAUTHORIZED",
  "message": "Okta-User-ID header is required",
  "timestamp": 1760896518572,
  "path": "/",
  "correlationId": "abc123"
}
```

#### 500 Internal Server Error
```json
{
  "error": "INTERNAL_ERROR",
  "message": "Failed to read contacts: Database connection error",
  "timestamp": 1760896518572,
  "path": "/",
  "correlationId": "abc123"
}
```

### Расширенные примеры использования

#### 1. Базовый поиск с пагинацией
```bash
curl -X GET "http://localhost:8040/?limit=10" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111"
```

#### 2. Поиск по тексту
```bash
curl -X GET "http://localhost:8040/?search=admin" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111"
```

#### 3. Фильтрация по роли и департаменту
```bash
curl -X GET "http://localhost:8040/?role=admin&department=IT" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111"
```

#### 4. Сортировка по имени пользователя
```bash
curl -X GET "http://localhost:8040/?sortBy=username&sortOrder=ASC" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111"
```

#### 5. Комбинированный запрос (поиск + фильтрация + сортировка)
```bash
curl -X GET "http://localhost:8040/?search=admin&role=admin&department=IT&sortBy=username&sortOrder=ASC&limit=5" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111"
```

#### 6. Получение контактов по конкретным ID
```bash
curl -X GET "http://localhost:8040/?ids=11111111-1111-1111-1111-111111111111,22222222-2222-2222-2222-222222222222" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111"
```

#### 7. Пагинация с курсором
```bash
curl -X GET "http://localhost:8040/?limit=5&cursor=2025-10-18T13:29:20.728567" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111"
```

#### 8. Фильтрация по статусу онлайн
```bash
curl -X GET "http://localhost:8040/?is_online=true" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111"
```

#### 9. Поиск по email домену
```bash
curl -X GET "http://localhost:8040/?email=company.com" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111"
```

#### 10. Сортировка по дате создания (новые сначала)
```bash
curl -X GET "http://localhost:8040/?sortBy=created_at&sortOrder=DESC" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111"
```

### Детальное описание параметров

#### 🔍 Параметры поиска
| Параметр | Описание | Пример | Примечание |
|----------|----------|--------|------------|
| `search` | Глобальный поиск по всем текстовым полям | `?search=john` | Ищет в username, firstName, lastName, displayName, email, phone, statusMessage, department, rank, position, company |
| `cursor` | Курсор для пагинации | `?cursor=2025-10-18T13:29:20.728567` | Время создания последнего контакта на предыдущей странице |
| `limit` | Количество контактов на страницу | `?limit=20` | От 1 до 100 (по умолчанию из конфигурации) |

#### 🎯 Параметры фильтрации
| Параметр | Тип фильтра | Описание | Пример |
|----------|-------------|----------|--------|
| `role` | Точное совпадение | Фильтр по роли | `?role=admin` |
| `department` | Частичное совпадение | Фильтр по департаменту | `?department=IT` |
| `company` | Частичное совпадение | Фильтр по компании | `?company=Microsoft` |
| `is_online` | Точное совпадение | Фильтр по статусу онлайн | `?is_online=true` |
| `locale` | Точное совпадение | Фильтр по локали | `?locale=ru` |
| `timezone` | Точное совпадение | Фильтр по часовому поясу | `?timezone=Europe/Moscow` |
| `username` | Частичное совпадение | Фильтр по имени пользователя | `?username=john` |
| `email` | Частичное совпадение | Фильтр по email | `?email=company.com` |
| `phone` | Частичное совпадение | Фильтр по телефону | `?phone=123` |
| `firstName` | Частичное совпадение | Фильтр по имени | `?firstName=John` |
| `lastName` | Частичное совпадение | Фильтр по фамилии | `?lastName=Smith` |
| `displayName` | Частичное совпадение | Фильтр по отображаемому имени | `?displayName=John` |
| `statusMessage` | Частичное совпадение | Фильтр по статусному сообщению | `?statusMessage=away` |
| `rank` | Частичное совпадение | Фильтр по рангу | `?rank=senior` |
| `position` | Частичное совпадение | Фильтр по должности | `?position=developer` |

#### 📊 Параметры сортировки
| Параметр | Описание | Возможные значения |
|----------|----------|-------------------|
| `sortBy` | Поле для сортировки | `created_at`, `updated_at`, `username`, `firstName`, `lastName`, `email`, `role`, `department`, `company` |
| `sortOrder` | Порядок сортировки | `ASC` (по возрастанию), `DESC` (по убыванию) |

#### 🆔 Параметры получения по ID
| Параметр | Описание | Пример | Ограничения |
|----------|----------|--------|-------------|
| `ids` | Список UUID контактов через запятую | `?ids=11111111-1111-1111-1111-111111111111,22222222-2222-2222-2222-222222222222` | Максимум 100 ID |

### Логика работы

#### 🔍 Алгоритм поиска
1. **Глобальный поиск**: Если указан параметр `search`, ищет по всем текстовым полям
2. **Применение фильтров**: Добавляет условия фильтрации для каждого указанного параметра
3. **Курсорная пагинация**: Если указан `cursor`, фильтрует записи по времени создания
4. **Сортировка**: Сортирует результат по указанному полю и порядку
5. **Лимит**: Ограничивает количество результатов

#### 📄 Логика пагинации
- **hasMore**: `true` если есть еще данные после текущей страницы
- **nextCursor**: Время создания последнего контакта на текущей странице
- **totalCount**: Только для запросов по `ids`, показывает количество найденных контактов

#### 🎯 Логика фильтрации
- **Точное совпадение**: `role`, `is_online`, `locale`, `timezone`
- **Частичное совпадение**: Все остальные поля (использует `LIKE` с `%`)
- **Комбинирование**: Все фильтры применяются с оператором `AND`

### Примеры использования

### Особенности реализации

#### 🖼️ Avatar URL
- **Автоматическая генерация**: При создании контакта автоматически генерируется `avatarUrl` в формате `{AVATAR_SERVICE_URL}/avatars/{user_id}/download`
- **Конфигурация**: URL сервиса аватаров настраивается через переменную окружения `AVATAR_SERVICE_URL` (по умолчанию `http://localhost:8060`)
- **Обновление**: При обновлении контакта можно изменить `avatarUrl` вручную, если необходимо

#### 🔍 Глобальный поиск
- Поиск выполняется по полям: `username`, `firstName`, `lastName`, `displayName`, `email`, `phone`, `statusMessage`, `department`, `rank`, `position`, `company`
- Поиск нечувствителен к регистру
- Использует оператор `LIKE` с `%` для частичного совпадения

#### 🎯 Фильтрация
- **Точное совпадение**: `role`, `is_online`, `locale`, `timezone`
- **Частичное совпадение**: все остальные поля
- Можно комбинировать несколько фильтров
- Фильтры применяются с оператором `AND`

#### 📊 Сортировка
- По умолчанию сортировка по `created_at DESC`
- Поддерживаются только безопасные поля для сортировки
- При неверном поле сортировки используется `created_at`

#### 📄 Пагинация
- Курсорная пагинация на основе времени создания
- `hasMore: true` означает, что есть еще данные
- `nextCursor` содержит время создания последнего контакта на текущей странице
- Для запросов по ID пагинация не применяется (`hasMore: false`, `nextCursor: null`)

#### 🆔 Получение по ID
- Максимум 100 ID за один запрос
- Возвращает `totalCount` с количеством найденных контактов
- Несуществующие ID игнорируются (не вызывают ошибку)
- Результат сортируется по `created_at DESC`

### Ограничения
- Максимальный лимит: 100 контактов на страницу
- Максимум 100 ID в параметре `ids`
- Все временные поля в формате ISO 8601
- UUID должны быть в стандартном формате с дефисами

### Версионирование
- Текущая версия API: v1
- Обратная совместимость поддерживается
- Новые поля добавляются как nullable
