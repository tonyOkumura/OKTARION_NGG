# 🚀 Руководство по созданию микросервиса на основе эталона

Этот документ содержит пошаговую инструкцию для создания нового микросервиса на основе эталонного микросервиса городов.

## 📋 Пример: Создание микросервиса задач (events)

Предположим, вы хотите создать микросервис для управления задачами (events) вместо городов.

## 🔄 Пошаговая инструкция

### Шаг 1: Копирование проекта

```bash
# Скопируйте эталонный проект
cp -r contact_micro events_micro
cd events_micro

# Очистите git историю (если нужно)
rm -rf .git
git init
```

### Шаг 2: Обновление конфигурации проекта

#### 2.1 Обновите `build.gradle.kts`:
```kotlin
// Измените название проекта
rootProject.name = "events-microservice"

// Обновите зависимости если нужно
dependencies {
    // Оставьте все как есть, зависимости универсальные
}
```

#### 2.2 Обновите `settings.gradle.kts`:
```kotlin
rootProject.name = "events-microservice"
```

#### 2.3 Обновите `docker-compose.yml`:
```yaml
services:
  # Измените названия сервисов
  events-service:
    build: .
    container_name: events_microservice
    ports:
      - "${SERVER_PORT:-8050}:${SERVER_PORT:-8050}"  # Измените порт
    environment:
      # Обновите переменные
      SERVICE_NAME: events-service
      POSTGRES_URL: jdbc:postgresql://postgres:5432/eventsdb
      POSTGRES_USER: eventsuser
      POSTGRES_PASSWORD: eventspass
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - events_network  # Измените название сети
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:${SERVER_PORT:-8050}/health"]

  postgres:
    image: postgres:15-alpine
    container_name: events_postgres
    environment:
      POSTGRES_DB: eventsdb  # Измените название БД
      POSTGRES_USER: eventsuser
      POSTGRES_PASSWORD: eventspass
    ports:
      - "5433:5432"  # Измените порт чтобы не конфликтовать
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - events_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U eventsuser -d eventsdb"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:

networks:
  events_network:
    driver: bridge
```

#### 2.4 Обновите `env.example`:
```bash
# Environment variables for the events microservice
# Copy this file to .env and customize for your specific service

# Database configuration
POSTGRES_URL=jdbc:postgresql://postgres:5432/eventsdb
POSTGRES_USER=eventsuser
POSTGRES_PASSWORD=eventspass
DB_MAX_POOL_SIZE=10

# Server configuration
SERVER_PORT=8050
SERVER_HOST=0.0.0.0
ENVIRONMENT=development

# Logging configuration
LOG_LEVEL=INFO
LOG_CORRELATION_ID=true

# Security configuration
CORS_ENABLED=true
CORS_ORIGINS=*
RATE_LIMIT_ENABLED=true
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_WINDOW_MINUTES=1

# Monitoring (for future use)
METRICS_ENABLED=false
TRACING_ENABLED=false

# Service specific configuration
SERVICE_NAME=events-service
SERVICE_VERSION=1.0.0
SERVICE_DESCRIPTION=event management microservice
```

### Шаг 3: Обновление базы данных

#### 3.1 Создайте новый `init.sql`:
```sql
-- Создание таблицы задач
CREATE TABLE IF NOT EXISTS events (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
    assignee VARCHAR(100),
    due_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Создание индексов
CREATE INDEX IF NOT EXISTS idx_events_status ON events(status);
CREATE INDEX IF NOT EXISTS idx_events_assignee ON events(assignee);
CREATE INDEX IF NOT EXISTS idx_events_due_date ON events(due_date);

-- Вставка тестовых данных
INSERT INTO events (title, description, status, priority, assignee, due_date) VALUES
('Implement user authentication', 'Add JWT-based authentication system', 'PENDING', 'HIGH', 'john.doe', '2024-01-15 18:00:00'),
('Fix database connection pool', 'Resolve connection timeout issues', 'IN_PROGRESS', 'MEDIUM', 'jane.smith', '2024-01-20 17:00:00'),
('Add API documentation', 'Generate OpenAPI documentation', 'COMPLETED', 'LOW', 'bob.wilson', '2024-01-10 16:00:00');
```

### Шаг 4: Обновление моделей данных

#### 4.1 Обновите `src/main/kotlin/com/example/model/CitySchema.kt` → `eventSchema.kt`:

```kotlin
package com.example.model

import kotlinx.serialization.Serializable
import java.sql.Connection
import java.sql.PreparedStatement
import java.sql.ResultSet
import java.sql.SQLException
import org.slf4j.LoggerFactory

@Serializable
data class event(
    val id: Int = 0,
    val title: String,
    val description: String? = null,
    val status: String = "PENDING",
    val priority: String = "MEDIUM",
    val assignee: String? = null,
    val dueDate: String? = null
)

@Serializable
data class ValidationError(
    val field: String,
    val message: String
)

class eventService(private val connection: Connection) {
    private val log = LoggerFactory.getLogger(eventService::class.java)

    fun create(event: event): Int {
        val sql = """
            INSERT INTO events (title, description, status, priority, assignee, due_date)
            VALUES (?, ?, ?, ?, ?, ?)
        """.trimIndent()
        
        return try {
            val statement = connection.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)
            statement.setString(1, event.title)
            statement.setString(2, event.description)
            statement.setString(3, event.status)
            statement.setString(4, event.priority)
            statement.setString(5, event.assignee)
            statement.setTimestamp(6, event.dueDate?.let { java.sql.Timestamp.valueOf(it) })
            
            statement.executeUpdate()
            val generatedKeys = statement.generatedKeys
            generatedKeys.next()
            val id = generatedKeys.getInt(1)
            log.info("Created event with ID: $id")
            id
        } catch (e: SQLException) {
            log.error("Error creating event", e)
            throw e
        }
    }

    fun read(id: Int): event {
        val sql = "SELECT * FROM events WHERE id = ?"
        
        return try {
            val statement = connection.prepareStatement(sql)
            statement.setInt(1, id)
            val resultSet = statement.executeQuery()
            
            if (resultSet.next()) {
                mapResultSetToevent(resultSet)
            } else {
                throw NoSuchElementException("event with ID $id not found")
            }
        } catch (e: SQLException) {
            log.error("Error reading event with ID: $id", e)
            throw e
        }
    }

    fun update(id: Int, event: event) {
        val sql = """
            UPDATE events 
            SET title = ?, description = ?, status = ?, priority = ?, assignee = ?, due_date = ?, updated_at = CURRENT_TIMESTAMP
            WHERE id = ?
        """.trimIndent()
        
        try {
            val statement = connection.prepareStatement(sql)
            statement.setString(1, event.title)
            statement.setString(2, event.description)
            statement.setString(3, event.status)
            statement.setString(4, event.priority)
            statement.setString(5, event.assignee)
            statement.setTimestamp(6, event.dueDate?.let { java.sql.Timestamp.valueOf(it) })
            statement.setInt(7, id)
            
            val rowsAffected = statement.executeUpdate()
            if (rowsAffected == 0) {
                throw NoSuchElementException("event with ID $id not found")
            }
            log.info("Updated event with ID: $id")
        } catch (e: SQLException) {
            log.error("Error updating event with ID: $id", e)
            throw e
        }
    }

    fun delete(id: Int) {
        val sql = "DELETE FROM events WHERE id = ?"
        
        try {
            val statement = connection.prepareStatement(sql)
            statement.setInt(1, id)
            
            val rowsAffected = statement.executeUpdate()
            if (rowsAffected == 0) {
                throw NoSuchElementException("event with ID $id not found")
            }
            log.info("Deleted event with ID: $id")
        } catch (e: SQLException) {
            log.error("Error deleting event with ID: $id", e)
            throw e
        }
    }

    private fun mapResultSetToevent(resultSet: ResultSet): event {
        return event(
            id = resultSet.getInt("id"),
            title = resultSet.getString("title"),
            description = resultSet.getString("description"),
            status = resultSet.getString("status"),
            priority = resultSet.getString("priority"),
            assignee = resultSet.getString("assignee"),
            dueDate = resultSet.getTimestamp("due_date")?.toString()
        )
    }
}
```

### Шаг 5: Обновление контроллера

#### 5.1 Обновите `src/main/kotlin/com/example/controller/CitiesRouting.kt` → `eventsRouting.kt`:

```kotlin
package com.example.controller

import com.example.model.event
import com.example.model.eventService
import com.example.model.ValidationError
import com.example.plugin.respondValidationError
import com.example.plugin.respondInternalError
import com.example.plugin.respondBadRequest
import com.example.plugin.respondNotFound
import com.example.plugin.validateevent
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import java.sql.Connection

fun Application.configureeventsRouting(dbConnection: Connection) {
    val eventService = eventService(dbConnection)
    
    routing {
        // Create event
        post("/events") {
            try {
                val event = call.receive<event>()
                
                // Валидация
                val validationErrors = validateevent(event)
                if (validationErrors.isNotEmpty()) {
                    call.respondValidationError("Validation failed", validationErrors)
                    return@post
                }
                
                val id = eventService.create(event)
                call.respond(HttpStatusCode.Created, mapOf("id" to id))
            } catch (e: Exception) {
                call.respondInternalError("Failed to create event: ${e.message}")
            }
        }

        // Read event
        get("/events/{id}") {
            try {
                val id = call.parameters["id"]?.toIntOrNull() 
                    ?: throw IllegalArgumentException("Invalid event ID format")
                
                val event = eventService.read(id)
                call.respond(HttpStatusCode.OK, event)
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid event ID")
            } catch (e: Exception) {
                call.respondNotFound("event not found")
            }
        }

        // Update event
        put("/events/{id}") {
            try {
                val id = call.parameters["id"]?.toIntOrNull() 
                    ?: throw IllegalArgumentException("Invalid event ID format")
                
                val event = call.receive<event>()
                
                // Валидация
                val validationErrors = validateevent(event)
                if (validationErrors.isNotEmpty()) {
                    call.respondValidationError("Validation failed", validationErrors)
                    return@put
                }
                
                eventService.update(id, event)
                call.respond(HttpStatusCode.OK, mapOf("message" to "event updated successfully"))
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid event ID")
            } catch (e: Exception) {
                call.respondNotFound("event not found")
            }
        }

        // Delete event
        delete("/events/{id}") {
            try {
                val id = call.parameters["id"]?.toIntOrNull() 
                    ?: throw IllegalArgumentException("Invalid event ID format")
                
                eventService.delete(id)
                call.respond(HttpStatusCode.OK, mapOf("message" to "event deleted successfully"))
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid event ID")
            } catch (e: Exception) {
                call.respondNotFound("event not found")
            }
        }

        // Get all events (дополнительный endpoint)
        get("/events") {
            try {
                val events = eventService.getAll()
                call.respond(HttpStatusCode.OK, events)
            } catch (e: Exception) {
                call.respondInternalError("Failed to get events: ${e.message}")
            }
        }
    }
}
```

### Шаг 6: Обновление валидации

#### 6.1 Обновите `src/main/kotlin/com/example/plugin/Validation.kt`:

```kotlin
package com.example.plugin

import com.example.model.event
import com.example.model.ValidationError
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.plugins.requestvalidation.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import kotlinx.serialization.Serializable

fun Application.configureValidation() {
    install(RequestValidation) {
        validate<event> { event ->
            val errors = validateevent(event)
            if (errors.isEmpty()) {
                ValidationResult.Valid
            } else {
                ValidationResult.Invalid(errors.joinToString(", ") { "${it.field}: ${it.message}" })
            }
        }
    }
}

// Функция валидации задачи
fun validateevent(event: event): List<ValidationError> {
    val errors = mutableListOf<ValidationError>()
    
    if (event.title.isBlank()) {
        errors.add(ValidationError("title", "event title cannot be blank"))
    } else if (event.title.length > 255) {
        errors.add(ValidationError("title", "event title cannot exceed 255 characters"))
    }
    
    if (event.description != null && event.description.length > 1000) {
        errors.add(ValidationError("description", "event description cannot exceed 1000 characters"))
    }
    
    val validStatuses = listOf("PENDING", "IN_PROGRESS", "COMPLETED", "CANCELLED")
    if (!validStatuses.contains(event.status.uppercase())) {
        errors.add(ValidationError("status", "Status must be one of: ${validStatuses.joinToString(", ")}"))
    }
    
    val validPriorities = listOf("LOW", "MEDIUM", "HIGH", "URGENT")
    if (!validPriorities.contains(event.priority.uppercase())) {
        errors.add(ValidationError("priority", "Priority must be one of: ${validPriorities.joinToString(", ")}"))
    }
    
    if (event.assignee != null && event.assignee.length > 100) {
        errors.add(ValidationError("assignee", "Assignee name cannot exceed 100 characters"))
    }
    
    return errors
}
```

### Шаг 7: Обновление инфраструктуры

#### 7.1 Обновите `src/main/kotlin/com/example/infrastructure/Databases.kt`:

```kotlin
package com.example.infrastructure

import com.example.config.getAppConfig
import com.example.controller.configureeventsRouting  // Измените импорт
import io.ktor.server.application.*
import java.sql.Connection
import java.sql.DriverManager
import org.slf4j.LoggerFactory

fun Application.configureDatabases() {
    val dbConnection: Connection = connectToPostgres(embedded = false)
    
    // Configure events routing with database connection
    configureeventsRouting(dbConnection)  // Измените вызов
    
    // Kafka configuration temporarily disabled
    // install(Kafka) {
    //     schemaRegistryUrl = "my.schemaRegistryUrl"
    //     val myTopic = TopicName.named("my-topic")
    //     topic(myTopic) {
    //         partitions = 1
    //         replicas = 1
    //         config = mapOf("cleanup.policy" to "delete")
    //     }
    // }
}

private val log = LoggerFactory.getLogger("com.example.Databases")

/**
 * Makes a connection to a Postgres database.
 *
 * In order to connect to your running Postgres process,
 * please specify the following parameters in your configuration file:
 * - postgres.url -- Url of your running database process.
 * - postgres.user -- Username for database connection
 * - postgres.password -- Password for database connection
 *
 * If you don't have a database process running yet, you may need to [download]((https://www.postgresql.org/download/))
 * and install Postgres and follow the instructions [here](https://postgresapp.com/).
 * Then, you would be able to edit your url,  which is usually "jdbc:postgresql://host:port/database", as well as
 * user and password values.
 *
 *
 * @param embedded -- if [true] defaults to an embedded database for tests that runs locally in the same process.
 * In this case you don't have to provide any parameters in configuration file, and you don't have to run a process.
 *
 * @return [Connection] that represent connection to the database. Please, don't forget to close this connection when
 * your application shuts down by calling [Connection.close]
 * */
fun Application.connectToPostgres(embedded: Boolean): Connection {
    Class.forName("org.postgresql.Driver")
    if (embedded) {
        log.info("Using embedded H2 database for testing; replace this flag to use postgres")
        return DriverManager.getConnection("jdbc:h2:mem:test;DB_CLOSE_DELAY=-1", "root", "")
    } else {
        val config = getAppConfig()
        log.info("Connecting to postgres database at ${config.database.url}")
        return DriverManager.getConnection(config.database.url, config.database.user, config.database.password)
    }
}
```

### Шаг 8: Обновление README

#### 8.1 Обновите `README.md`:

```markdown
# Микросервис задач (events Microservice)

Микросервис для управления задачами, построенный на Ktor с PostgreSQL базой данных.

## API Endpoints

| Метод | Путь | Описание |
|-------|------|----------|
| POST | `/events` | Создать новую задачу |
| GET | `/events` | Получить все задачи |
| GET | `/events/{id}` | Получить задачу по ID |
| PUT | `/events/{id}` | Обновить задачу |
| DELETE | `/events/{id}` | Удалить задачу |

### Примеры запросов

**Создание задачи:**
```bash
curl -X POST http://localhost:8050/events \
  -H "Content-Type: application/json" \
  -d '{"title": "Implement authentication", "description": "Add JWT auth", "status": "PENDING", "priority": "HIGH", "assignee": "john.doe"}'
```

**Получение всех задач:**
```bash
curl http://localhost:8050/events
```

**Получение задачи:**
```bash
curl http://localhost:8050/events/1
```
```

### Шаг 9: Тестирование

#### 9.1 Запустите новый микросервис:

```bash
# Скопируйте конфигурацию
cp env.example .env

# Запустите сервисы
docker-compose up --build -d

# Проверьте статус
docker-compose ps

# Проверьте логи
docker-compose logs -f events-service

# Протестируйте API
curl http://localhost:8050/health
curl http://localhost:8050/events
```

#### 9.2 Протестируйте все endpoints:

```bash
# Создание задачи
curl -X POST http://localhost:8050/events \
  -H "Content-Type: application/json" \
  -d '{"title": "Test event", "description": "Test Description", "status": "PENDING", "priority": "MEDIUM"}'

# Получение задачи
curl http://localhost:8050/events/1

# Обновление задачи
curl -X PUT http://localhost:8050/events/1 \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated event", "description": "Updated Description", "status": "IN_PROGRESS", "priority": "HIGH"}'

# Удаление задачи
curl -X DELETE http://localhost:8050/events/1
```

## 🎯 Чек-лист для создания нового микросервиса

- [ ] Скопировать эталонный проект
- [ ] Обновить названия в `build.gradle.kts` и `settings.gradle.kts`
- [ ] Обновить `docker-compose.yml` (порты, названия сервисов, БД)
- [ ] Обновить `env.example` (порты, названия БД, сервиса)
- [ ] Создать новый `init.sql` с нужными таблицами
- [ ] Обновить модель данных (заменить City на вашу сущность)
- [ ] Обновить сервис (CRUD операции для новой сущности)
- [ ] Обновить контроллер (заменить cities на ваши endpoints)
- [ ] Обновить валидацию (правила для новой сущности)
- [ ] Обновить инфраструктуру (импорты и вызовы)
- [ ] Обновить README (описание API и примеры)
- [ ] Протестировать все endpoints
- [ ] Проверить health checks
- [ ] Проверить логирование и обработку ошибок

## 🔧 Дополнительные настройки

### Добавление новых полей

Если нужно добавить новые поля в модель:

1. Обновите SQL схему в `init.sql`
2. Обновите модель данных
3. Обновите сервис (CRUD операции)
4. Обновите валидацию
5. Обновите примеры в README

### Добавление новых endpoints

Если нужно добавить новые endpoints:

1. Добавьте методы в сервис
2. Добавьте routes в контроллер
3. Обновите документацию в README

### Изменение портов

Если нужно изменить порты:

1. Обновите `SERVER_PORT` в `env.example`
2. Обновите порты в `docker-compose.yml`
3. Обновите примеры в README

## 📚 Полезные команды

```bash
# Пересборка и перезапуск
docker-compose up --build -d

# Просмотр логов
docker-compose logs -f events-service

# Остановка сервисов
docker-compose down

# Очистка данных
docker-compose down -v

# Подключение к БД
docker exec -it events_postgres psql -U eventsuser -d eventsdb

# Проверка статуса
docker-compose ps
```

---

**Готово! Теперь у вас есть полнофункциональный микросервис задач на основе эталонного микросервиса.** 🎉
