package com.file_micro.config

import io.ktor.server.application.*

data class AppConfig(
    val server: ServerConfig,
    val minio: MinIOConfig,
    val logging: LoggingConfig,
    val security: SecurityConfig,
    val pagination: PaginationConfig
)

data class ServerConfig(
    val port: Int,
    val host: String,
    val environment: String
)

data class MinIOConfig(
    val endpoint: String,
    val accessKey: String,
    val secretKey: String,
    val bucketName: String = "files",
    val region: String = "us-east-1",
    val externalUrl: String? = null // Внешний URL для presigned URLs
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
                ?: 8060,
            host = System.getenv("SERVER_HOST") 
                ?: environment.config.propertyOrNull("server.host")?.getString() 
                ?: "0.0.0.0",
            environment = System.getenv("ENVIRONMENT") 
                ?: environment.config.propertyOrNull("environment")?.getString() 
                ?: "development"
        ),
        minio = MinIOConfig(
            endpoint = System.getenv("MINIO_ENDPOINT") 
                ?: environment.config.propertyOrNull("minio.endpoint")?.getString()
                ?: "http://minio:9300",
            accessKey = System.getenv("MINIO_ACCESS_KEY")
                ?: environment.config.propertyOrNull("minio.accessKey")?.getString()
                ?: "minioadmin",
            secretKey = System.getenv("MINIO_SECRET_KEY")
                ?: environment.config.propertyOrNull("minio.secretKey")?.getString()
                ?: "minioadmin",
            bucketName = System.getenv("MINIO_BUCKET_NAME")
                ?: environment.config.propertyOrNull("minio.bucketName")?.getString()
                ?: "files",
            region = System.getenv("MINIO_REGION")
                ?: environment.config.propertyOrNull("minio.region")?.getString()
                ?: "us-east-1",
            externalUrl = System.getenv("MINIO_EXTERNAL_URL")
                ?: environment.config.propertyOrNull("minio.externalUrl")?.getString()
                ?: "http://localhost:9300"
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
