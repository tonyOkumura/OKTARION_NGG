# Contact Microservice API Documentation

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

### Примеры использования

#### 1. Получение всех контактов с пагинацией
```bash
curl -X GET "http://localhost:8040/?limit=10" \
  -H "Okta-User-ID: 11111111-1111-1111-1111-111111111111"
```

#### 2. Поиск контактов по тексту
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

#### 5. Комбинированный запрос
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
