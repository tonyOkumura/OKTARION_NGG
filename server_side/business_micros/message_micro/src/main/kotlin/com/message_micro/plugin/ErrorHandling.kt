package com.example.message.plugin

import com.example.model.ErrorResponse
import com.example.model.StandardErrors
import com.example.model.ValidationErrorResponse
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.plugins.statuspages.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import kotlinx.serialization.SerializationException
import org.slf4j.LoggerFactory
import java.sql.SQLException

fun Application.configureErrorHandling() {
    val logger = LoggerFactory.getLogger("ErrorHandler")
    
    install(StatusPages) {
        // Обработка исключений валидации
        exception<IllegalArgumentException> { call, cause ->
            logger.warn("Validation error: ${cause.message}", cause)
            val errorResponse = ErrorResponse(
                error = StandardErrors.VALIDATION_ERROR,
                message = cause.message ?: "Validation failed",
                timestamp = System.currentTimeMillis(),
                path = call.request.uri,
                correlationId = call.request.header("X-Correlation-ID")
            )
            call.respond(HttpStatusCode.BadRequest, errorResponse)
        }
        
        // Обработка ошибок сериализации
        exception<SerializationException> { call, cause ->
            logger.warn("Serialization error: ${cause.message}", cause)
            val errorResponse = ErrorResponse(
                error = StandardErrors.BAD_REQUEST,
                message = "Invalid request format: ${cause.message}",
                timestamp = System.currentTimeMillis(),
                path = call.request.uri,
                correlationId = call.request.header("X-Correlation-ID")
            )
            call.respond(HttpStatusCode.BadRequest, errorResponse)
        }
        
        // Обработка ошибок базы данных
        exception<SQLException> { call, cause ->
            logger.error("Database error: ${cause.message}", cause)
            val errorResponse = ErrorResponse(
                error = StandardErrors.DATABASE_ERROR,
                message = "Database operation failed",
                timestamp = System.currentTimeMillis(),
                path = call.request.uri,
                correlationId = call.request.header("X-Correlation-ID")
            )
            call.respond(HttpStatusCode.InternalServerError, errorResponse)
        }
        
        // Обработка общих исключений
        exception<Exception> { call, cause ->
            logger.error("Unexpected error: ${cause.message}", cause)
            val errorResponse = ErrorResponse(
                error = StandardErrors.INTERNAL_ERROR,
                message = "An unexpected error occurred",
                timestamp = System.currentTimeMillis(),
                path = call.request.uri,
                correlationId = call.request.header("X-Correlation-ID")
            )
            call.respond(HttpStatusCode.InternalServerError, errorResponse)
        }
        
        // Обработка HTTP статусов
        status(HttpStatusCode.NotFound) { call, status ->
            val errorResponse = ErrorResponse(
                error = StandardErrors.NOT_FOUND,
                message = "Resource not found",
                timestamp = System.currentTimeMillis(),
                path = call.request.uri,
                correlationId = call.request.header("X-Correlation-ID")
            )
            call.respond(status, errorResponse)
        }
        
        status(HttpStatusCode.MethodNotAllowed) { call, status ->
            val errorResponse = ErrorResponse(
                error = StandardErrors.BAD_REQUEST,
                message = "Method not allowed for this resource",
                timestamp = System.currentTimeMillis(),
                path = call.request.uri,
                correlationId = call.request.header("X-Correlation-ID")
            )
            call.respond(status, errorResponse)
        }
    }
}

// Extension функции для удобного создания ошибок
suspend fun ApplicationCall.respondNotFound(message: String = "Resource not found") {
    val errorResponse = ErrorResponse(
        error = StandardErrors.NOT_FOUND,
        message = message,
        timestamp = System.currentTimeMillis(),
        path = request.uri,
        correlationId = request.header("X-Correlation-ID")
    )
    respond(HttpStatusCode.NotFound, errorResponse)
}

suspend fun ApplicationCall.respondValidationError(message: String, validationErrors: List<com.example.model.ValidationError>) {
    val errorResponse = ValidationErrorResponse(
        message = message,
        timestamp = System.currentTimeMillis(),
        path = request.uri,
        correlationId = request.header("X-Correlation-ID"),
        validationErrors = validationErrors
    )
    respond(HttpStatusCode.BadRequest, errorResponse)
}

suspend fun ApplicationCall.respondBadRequest(message: String) {
    val errorResponse = ErrorResponse(
        error = StandardErrors.BAD_REQUEST,
        message = message,
        timestamp = System.currentTimeMillis(),
        path = request.uri,
        correlationId = request.header("X-Correlation-ID")
    )
    respond(HttpStatusCode.BadRequest, errorResponse)
}

suspend fun ApplicationCall.respondInternalError(message: String = "Internal server error") {
    val errorResponse = ErrorResponse(
        error = StandardErrors.INTERNAL_ERROR,
        message = message,
        timestamp = System.currentTimeMillis(),
        path = request.uri,
        correlationId = request.header("X-Correlation-ID")
    )
    respond(HttpStatusCode.InternalServerError, errorResponse)
}
