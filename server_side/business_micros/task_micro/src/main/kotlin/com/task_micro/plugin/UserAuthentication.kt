package com.task_micro.plugin

import com.task_micro.model.ErrorResponse
import com.task_micro.model.StandardErrors
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.plugins.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.util.*
import org.slf4j.LoggerFactory

// Константа для ключа атрибута пользователя
const val USER_ID_ATTRIBUTE_KEY = "okta_user_id"

// Extension функция для получения ID пользователя из контекста
fun ApplicationCall.getUserId(): String? {
    return attributes.getOrNull(AttributeKey(USER_ID_ATTRIBUTE_KEY))
}

// Extension функция для получения обязательного ID пользователя
fun ApplicationCall.requireUserId(): String {
    return getUserId() ?: throw BadRequestException("Okta-User-ID header is required")
}

fun Application.configureUserAuthentication() {
    val logger = LoggerFactory.getLogger("UserAuthentication")
    
    // Создаем атрибут для хранения ID пользователя
    val userIdAttribute = AttributeKey<String>(USER_ID_ATTRIBUTE_KEY)
    
    // Intercept для обработки заголовка Okta-User-ID
    intercept(ApplicationCallPipeline.Setup) {
        try {
            // Пропускаем OPTIONS запросы (CORS preflight)
            if (call.request.httpMethod == io.ktor.http.HttpMethod.Options) {
                proceed()
                return@intercept
            }
            
            val oktaUserId = call.request.header("Okta-User-ID")
            
            if (oktaUserId.isNullOrBlank()) {
                logger.warn("Missing Okta-User-ID header in request to ${call.request.uri}")
                val errorResponse = ErrorResponse(
                    error = StandardErrors.UNAUTHORIZED,
                    message = "Okta-User-ID header is required",
                    timestamp = System.currentTimeMillis(),
                    path = call.request.uri,
                    correlationId = call.request.header("X-Correlation-ID")
                )
                call.respond(HttpStatusCode.Unauthorized, errorResponse)
                finish()
                return@intercept
            }
            
            // Валидация формата Okta User ID (обычно UUID или email)
            if (!isValidOktaUserId(oktaUserId)) {
                logger.warn("Invalid Okta-User-ID format: $oktaUserId in request to ${call.request.uri}")
                val errorResponse = ErrorResponse(
                    error = StandardErrors.BAD_REQUEST,
                    message = "Invalid Okta-User-ID format",
                    timestamp = System.currentTimeMillis(),
                    path = call.request.uri,
                    correlationId = call.request.header("X-Correlation-ID")
                )
                call.respond(HttpStatusCode.BadRequest, errorResponse)
                finish()
                return@intercept
            }
            
            // Сохраняем ID пользователя в атрибутах контекста
            call.attributes.put(userIdAttribute, oktaUserId)
            
            logger.debug("Authenticated user: $oktaUserId for request to ${call.request.uri}")
            
        } catch (e: Exception) {
            logger.error("Error processing Okta-User-ID header", e)
            val errorResponse = ErrorResponse(
                error = StandardErrors.INTERNAL_ERROR,
                message = "Authentication processing failed",
                timestamp = System.currentTimeMillis(),
                path = call.request.uri,
                correlationId = call.request.header("X-Correlation-ID")
            )
            call.respond(HttpStatusCode.InternalServerError, errorResponse)
            finish()
            return@intercept
        }
    }
}

// Функция валидации формата Okta User ID - только UUID
private fun isValidOktaUserId(userId: String): Boolean {
    // Принимаем только UUID формат (с дефисами или без)
    val uuidWithDashes = Regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", RegexOption.IGNORE_CASE)
    val uuidWithoutDashes = Regex("^[0-9a-f]{32}$", RegexOption.IGNORE_CASE)
    
    return userId.matches(uuidWithDashes) || userId.matches(uuidWithoutDashes)
}

// Extension функции для удобного логирования с пользователем
fun ApplicationCall.logWithUser(level: String, message: String) {
    val userId = getUserId() ?: "unknown"
    val correlationId = request.header("X-Correlation-ID") ?: "unknown"
    
    when (level.lowercase()) {
        "info" -> org.slf4j.LoggerFactory.getLogger("UserActivity").info("User: $userId, CorrelationId: $correlationId - $message")
        "warn" -> org.slf4j.LoggerFactory.getLogger("UserActivity").warn("User: $userId, CorrelationId: $correlationId - $message")
        "error" -> org.slf4j.LoggerFactory.getLogger("UserActivity").error("User: $userId, CorrelationId: $correlationId - $message")
        "debug" -> org.slf4j.LoggerFactory.getLogger("UserActivity").debug("User: $userId, CorrelationId: $correlationId - $message")
    }
}
