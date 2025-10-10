package com.task_micro.model

import kotlinx.serialization.Serializable

@Serializable
data class ErrorResponse(
    val error: String,
    val message: String,
    val timestamp: Long,
    val path: String? = null,
    val correlationId: String? = null
)

@Serializable
data class ValidationError(
    val field: String,
    val message: String,
    val rejectedValue: String? = null
)

@Serializable
data class ValidationErrorResponse(
    val error: String = "VALIDATION_ERROR",
    val message: String,
    val timestamp: Long,
    val path: String? = null,
    val correlationId: String? = null,
    val validationErrors: List<ValidationError>
)

// Стандартные ошибки
object StandardErrors {
    const val NOT_FOUND = "NOT_FOUND"
    const val VALIDATION_ERROR = "VALIDATION_ERROR"
    const val INTERNAL_ERROR = "INTERNAL_ERROR"
    const val DATABASE_ERROR = "DATABASE_ERROR"
    const val BAD_REQUEST = "BAD_REQUEST"
    const val UNAUTHORIZED = "UNAUTHORIZED"
    const val FORBIDDEN = "FORBIDDEN"
    const val CONFLICT = "CONFLICT"
    const val SERVICE_UNAVAILABLE = "SERVICE_UNAVAILABLE"
}
