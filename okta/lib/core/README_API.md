# API Service Documentation

## Обзор

Этот модуль предоставляет полноценную систему для работы с API сервером, включающую:

- **Автоматическое управление токенами** из Supabase
- **Автоматическое обновление токенов** при истечении срока действия
- **Обработка ошибок** и повторные запросы
- **Логирование** всех API запросов
- **Типизированные репозитории** для каждого модуля

## 🎯 Зачем нужны все эти файлы констант?

### **1. `success_messages.dart`** ✅
**Цель**: Централизованное хранение всех сообщений об успешных операциях
**Преимущества**:
- Единообразие сообщений во всем приложении
- Легко изменить текст в одном месте
- Поддержка локализации в будущем
- Предотвращение опечаток

**Пример использования**:
```dart
Get.snackbar('Успех', SuccessMessages.loginSuccess);
LogService.i(SuccessMessages.dataRetrieved);
```

### **2. `error_messages.dart`** ❌
**Цель**: Централизованное хранение всех сообщений об ошибках
**Преимущества**:
- Консистентные сообщения об ошибках
- Легко добавлять новые типы ошибок
- Централизованное управление текстами
- Улучшенный UX

**Пример использования**:
```dart
Get.snackbar('Ошибка', ErrorMessages.invalidCredentials);
throw Exception(ErrorMessages.networkError);
```

### **3. `app_constants.dart`** ⚠️
**Цель**: Общие константы приложения (НЕ API настройки!)
**Содержит**:
- Информация о приложении (название, версия)
- Настройки Supabase
- Настройки хранилища (Hive)
- Пути к ресурсам
- Настройки пагинации

**ВАЖНО**: API настройки перенесены в `api_config.dart`

### **4. `api_endpoints.dart`** ✅
**Цель**: Централизованное хранение всех API endpoints
**Преимущества**:
- Нет магических строк в коде
- Легко изменить endpoint в одном месте
- Предотвращение опечаток в URL
- Автодополнение в IDE

**Пример использования**:
```dart
final response = await _apiService.get(ApiEndpoints.userProfile);
final response = await _apiService.post(ApiEndpoints.login, data: loginData);
```

## 🚀 Настройка

### 1. Обновите базовый URL

В файле `lib/core/config/api_config.dart`:

```dart
static const String baseUrl = 'https://your-api-server.com/api/v1';
```

### 2. Добавьте новые endpoints

В файле `lib/core/constants/api_endpoints.dart`:

```dart
// Добавьте новые endpoints
static const String newEndpoint = '/new-endpoint';
```

### 3. Добавьте новые сообщения

В файлах `success_messages.dart` и `error_messages.dart`:

```dart
// В success_messages.dart
static const String newSuccessMessage = 'New operation completed successfully';

// В error_messages.dart  
static const String newErrorMessage = 'New error occurred';
```

### 4. Инициализация

API сервисы автоматически инициализируются в `main.dart`. Никаких дополнительных действий не требуется.

## Использование

### Базовое использование

```dart
import 'package:get/get.dart';
import '../../core/core.dart';

class MyController extends GetxController {
  final MessagesRepository _messagesRepo = Get.find<MessagesRepository>();
  final TasksRepository _tasksRepo = Get.find<TasksRepository>();

  Future<void> loadData() async {
    try {
      // Загрузка сообщений
      final messagesResponse = await _messagesRepo.getMessages(
        page: 1,
        limit: 20,
        filters: {'unread_only': true},
      );
      
      if (messagesResponse.success) {
        final messages = messagesResponse.data!;
        // Обработка данных
      }
    } catch (e) {
      // Обработка ошибок
      Get.snackbar('Ошибка', e.toString());
    }
  }
}
```

### Работа с файлами

```dart
// Загрузка файла
final uploadResponse = await _filesRepo.uploadFile(
  '/path/to/file.jpg',
  metadata: {'description': 'Profile photo'},
  onProgress: (sent, total) {
    print('Progress: ${(sent / total * 100).toInt()}%');
  },
);

// Скачивание файла
await _filesRepo.downloadFile(
  'file-id-123',
  '/path/to/save/file.jpg',
  onProgress: (received, total) {
    print('Download progress: ${(received / total * 100).toInt()}%');
  },
);
```

### Прямое использование ApiService

```dart
final apiService = Get.find<ApiService>();

// GET запрос
final response = await apiService.get<Map<String, dynamic>>(
  '/custom-endpoint',
  queryParameters: {'param': 'value'},
);

// POST запрос
final response = await apiService.post<Map<String, dynamic>>(
  '/custom-endpoint',
  data: {'key': 'value'},
);
```

## Структура ответов

Все API ответы имеют единообразную структуру:

```dart
class ApiResponse<T> {
  final bool success;           // Успешность запроса
  final T? data;               // Данные ответа
  final String? message;       // Сообщение
  final int? statusCode;       // HTTP код
  final Map<String, dynamic>? errors; // Ошибки валидации
}
```

## Обработка ошибок

### Автоматическая обработка

- **401 Unauthorized**: Автоматическое обновление токена через Supabase
- **403 Forbidden**: Перенаправление на страницу логина
- **500 Server Error**: Логирование и уведомление пользователя

### Ручная обработка

```dart
try {
  final response = await _messagesRepo.getMessages();
  // Обработка успешного ответа
} on ApiError catch (e) {
  // Обработка ошибки API
  print('API Error: ${e.message}');
  print('Status Code: ${e.statusCode}');
} catch (e) {
  // Обработка других ошибок
  print('Unexpected error: $e');
}
```

## Репозитории

### MessagesRepository
- `getMessages()` - Получить список сообщений
- `sendMessage()` - Отправить сообщение
- `getMessage()` - Получить сообщение по ID
- `updateMessage()` - Обновить сообщение
- `deleteMessage()` - Удалить сообщение

### TasksRepository
- `getTasks()` - Получить список задач
- `createTask()` - Создать задачу
- `updateTask()` - Обновить задачу
- `deleteTask()` - Удалить задачу

### EventsRepository
- `getEvents()` - Получить список событий
- `createEvent()` - Создать событие
- `updateEvent()` - Обновить событие
- `deleteEvent()` - Удалить событие

### FilesRepository
- `getFiles()` - Получить список файлов
- `uploadFile()` - Загрузить файл
- `downloadFile()` - Скачать файл
- `deleteFile()` - Удалить файл

### ContactsRepository
- `getContacts()` - Получить список контактов
- `createContact()` - Создать контакт
- `updateContact()` - Обновить контакт
- `deleteContact()` - Удалить контакт

### UserRepository
- `getProfile()` - Получить профиль пользователя
- `updateProfile()` - Обновить профиль
- `uploadAvatar()` - Загрузить аватар

## Логирование

Все API запросы автоматически логируются:

```
[INFO] API Request: GET /messages
[DEBUG] Request data: {"page": 1, "limit": 20}
[INFO] API Response: 200 /messages
[DEBUG] Response data: {"success": true, "data": [...]}
```

## Безопасность

- **HTTPS**: Все запросы используют HTTPS
- **Токены**: Автоматическое добавление Bearer токенов из Supabase
- **Обновление токенов**: Автоматическое обновление при истечении срока
- **Валидация**: Проверка всех входящих данных

## Настройка таймаутов

В `api_constants.dart`:

```dart
static const Duration connectTimeout = Duration(seconds: 30);
static const Duration receiveTimeout = Duration(seconds: 30);
static const Duration sendTimeout = Duration(seconds: 30);
```

## Примеры использования в контроллерах

См. файл `lib/core/examples/example_api_controller.dart` для полного примера использования API сервисов в GetX контроллере.
