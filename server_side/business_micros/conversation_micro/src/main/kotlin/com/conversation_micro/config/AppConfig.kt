package com.conversation_micro.config

import io.ktor.server.application.*

data class AppConfig(
    val server: ServerConfig,
    val database: DatabaseConfig,
    val logging: LoggingConfig,
    val security: SecurityConfig,
    val pagination: PaginationConfig
)

data class ServerConfig(
    val port: Int,
    val host: String,
    val environment: String
)

data class DatabaseConfig(
    val url: String,
    val user: String,
    val password: String,
    val maxPoolSize: Int = 10
)

data class LoggingConfig(
    val level: String,
    val enableCorrelationId: Boolean = true
)

data class SecurityConfig(
    val enableCors: Boolean = true,
    val corsOrigins: List<String> = listOf("*"),
    val enableRateLimit: Boolean = true,
    val rateLimitRequests: Int = 100,
    val rateLimitWindowMinutes: Int = 1
)

data class PaginationConfig(
    val defaultLimit: Int = 50,
    val maxLimit: Int = 100
)

fun Application.getAppConfig(): AppConfig {
    return AppConfig(
        server = ServerConfig(
            port = System.getenv("SERVER_PORT")?.toIntOrNull() 
                ?: environment.config.propertyOrNull("server.port")?.getString()?.toIntOrNull() 
                ?: 8040,
            host = System.getenv("SERVER_HOST") 
                ?: environment.config.propertyOrNull("server.host")?.getString() 
                ?: "0.0.0.0",
            environment = System.getenv("ENVIRONMENT") 
                ?: environment.config.propertyOrNull("environment")?.getString() 
                ?: "development"
        ),
        database = DatabaseConfig(
            url = System.getenv("POSTGRES_URL") 
                ?: environment.config.propertyOrNull("postgres.url")?.getString()
                ?: "jdbc:postgresql://postgres:5432/contactdb",
            user = System.getenv("POSTGRES_USER")
                ?: environment.config.propertyOrNull("postgres.user")?.getString()
                ?: "contactuser",
            password = System.getenv("POSTGRES_PASSWORD")
                ?: environment.config.propertyOrNull("postgres.password")?.getString()
                ?: "contactpass",
            maxPoolSize = System.getenv("DB_MAX_POOL_SIZE")?.toIntOrNull() 
                ?: environment.config.propertyOrNull("db.maxPoolSize")?.getString()?.toIntOrNull() 
                ?: 10
        ),
        logging = LoggingConfig(
            level = System.getenv("LOG_LEVEL") 
                ?: environment.config.propertyOrNull("logging.level")?.getString() 
                ?: "INFO",
            enableCorrelationId = System.getenv("LOG_CORRELATION_ID")?.toBoolean() 
                ?: environment.config.propertyOrNull("logging.correlationId")?.getString()?.toBoolean() 
                ?: true
        ),
        security = SecurityConfig(
            enableCors = System.getenv("CORS_ENABLED")?.toBoolean() 
                ?: environment.config.propertyOrNull("security.cors.enabled")?.getString()?.toBoolean() 
                ?: true,
            corsOrigins = System.getenv("CORS_ORIGINS")?.split(",") 
                ?: environment.config.propertyOrNull("security.cors.origins")?.getString()?.split(",") 
                ?: listOf("*"),
            enableRateLimit = System.getenv("RATE_LIMIT_ENABLED")?.toBoolean() 
                ?: environment.config.propertyOrNull("security.rateLimit.enabled")?.getString()?.toBoolean() 
                ?: true,
            rateLimitRequests = System.getenv("RATE_LIMIT_REQUESTS")?.toIntOrNull() 
                ?: environment.config.propertyOrNull("security.rateLimit.requests")?.getString()?.toIntOrNull() 
                ?: 100,
            rateLimitWindowMinutes = System.getenv("RATE_LIMIT_WINDOW_MINUTES")?.toIntOrNull() 
                ?: environment.config.propertyOrNull("security.rateLimit.windowMinutes")?.getString()?.toIntOrNull() 
                ?: 1
        ),
        pagination = PaginationConfig(
            defaultLimit = System.getenv("PAGINATION_DEFAULT_LIMIT")?.toIntOrNull() 
                ?: environment.config.propertyOrNull("pagination.defaultLimit")?.getString()?.toIntOrNull() 
                ?: 50,
            maxLimit = System.getenv("PAGINATION_MAX_LIMIT")?.toIntOrNull() 
                ?: environment.config.propertyOrNull("pagination.maxLimit")?.getString()?.toIntOrNull() 
                ?: 100
        )
    )
}
