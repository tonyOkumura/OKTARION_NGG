package com.file_micro.plugin

import com.file_micro.model.FileUploadRequest
import com.file_micro.model.FileUpdateRequest
import com.file_micro.model.ValidationError
import com.file_micro.model.AvatarUploadRequest
import com.file_micro.model.AvatarValidationError
import io.ktor.server.application.*
import io.ktor.server.plugins.requestvalidation.*

fun Application.configureValidation() {
    install(RequestValidation) {
        // Validation будет настроена для нового функционала
    }
}

// Валидация для загрузки файлов
fun validateFileUpload(request: FileUploadRequest): List<ValidationError> {
    val errors = mutableListOf<ValidationError>()
    
    // Валидация имени файла
    if (request.fileName.isBlank()) {
        errors.add(ValidationError("fileName", "File name cannot be blank"))
    } else if (request.fileName.length > 255) {
        errors.add(ValidationError("fileName", "File name cannot exceed 255 characters"))
    } else if (!isValidFileName(request.fileName)) {
        errors.add(ValidationError("fileName", "File name contains invalid characters"))
    }
    
    // Валидация типа контента
    if (request.contentType != null && request.contentType.isBlank()) {
        errors.add(ValidationError("contentType", "Content type cannot be blank"))
    }
    
    // Валидация метаданных
    request.metadata.forEach { (key, value) ->
        if (key.isBlank()) {
            errors.add(ValidationError("metadata", "Metadata key cannot be blank"))
        } else if (key.length > 50) {
            errors.add(ValidationError("metadata", "Metadata key cannot exceed 50 characters"))
        }
        
        if (value.length > 200) {
            errors.add(ValidationError("metadata", "Metadata value cannot exceed 200 characters"))
        }
    }
    
    return errors
}

// Валидация для обновления файлов
fun validateFileUpdate(request: FileUpdateRequest): List<ValidationError> {
    val errors = mutableListOf<ValidationError>()
    
    // Валидация имени файла (если указано)
    if (request.fileName != null) {
        if (request.fileName.isBlank()) {
            errors.add(ValidationError("fileName", "File name cannot be blank"))
        } else if (request.fileName.length > 255) {
            errors.add(ValidationError("fileName", "File name cannot exceed 255 characters"))
        } else if (!isValidFileName(request.fileName)) {
            errors.add(ValidationError("fileName", "File name contains invalid characters"))
        }
    }
    
    // Валидация метаданных (если указаны)
    request.metadata?.forEach { (key, value) ->
        if (key.isBlank()) {
            errors.add(ValidationError("metadata", "Metadata key cannot be blank"))
        } else if (key.length > 50) {
            errors.add(ValidationError("metadata", "Metadata key cannot exceed 50 characters"))
        }
        
        if (value.length > 200) {
            errors.add(ValidationError("metadata", "Metadata value cannot exceed 200 characters"))
        }
    }
    
    return errors
}

// Вспомогательные функции валидации
private fun isValidFileName(fileName: String): Boolean {
    // Проверяем на наличие недопустимых символов
    val invalidChars = setOf('<', '>', ':', '"', '|', '?', '*', '\\', '/')
    return !fileName.any { it in invalidChars }
}

// Валидация размера файла (для использования в контроллерах)
fun validateFileSize(size: Long, maxSizeBytes: Long = 100 * 1024 * 1024): List<ValidationError> {
    val errors = mutableListOf<ValidationError>()
    
    if (size <= 0) {
        errors.add(ValidationError("fileSize", "File size must be greater than 0"))
    } else if (size > maxSizeBytes) {
        val maxSizeMB = maxSizeBytes / (1024 * 1024)
        errors.add(ValidationError("fileSize", "File size cannot exceed ${maxSizeMB}MB"))
    }
    
    return errors
}

// ===== ВАЛИДАЦИЯ ДЛЯ АВАТАРОК =====

// Валидация для загрузки аватарок
fun validateAvatarUpload(request: AvatarUploadRequest): List<AvatarValidationError> {
    val errors = mutableListOf<AvatarValidationError>()
    
    // Валидация типа контента
    if (request.contentType != null) {
        if (request.contentType.isBlank()) {
            errors.add(AvatarValidationError("contentType", "Content type cannot be blank"))
        } else if (!isValidAvatarContentType(request.contentType)) {
            errors.add(AvatarValidationError("contentType", "Only image files are allowed for avatars (JPEG, PNG, GIF, WebP)"))
        }
    }
    
    return errors
}

// Валидация размера аватарки
fun validateAvatarSize(size: Long, maxSizeBytes: Long = 5 * 1024 * 1024): List<AvatarValidationError> {
    val errors = mutableListOf<AvatarValidationError>()
    
    if (size <= 0) {
        errors.add(AvatarValidationError("fileSize", "Avatar size must be greater than 0"))
    } else if (size > maxSizeBytes) {
        val maxSizeMB = maxSizeBytes / (1024 * 1024)
        errors.add(AvatarValidationError("fileSize", "Avatar size cannot exceed ${maxSizeMB}MB"))
    }
    
    return errors
}

// Валидация типа файла для аватарок
fun validateAvatarType(contentType: String?): List<AvatarValidationError> {
    val errors = mutableListOf<AvatarValidationError>()
    
    if (contentType != null && !isValidAvatarContentType(contentType)) {
        errors.add(AvatarValidationError("contentType", "Only image files are allowed for avatars. Supported formats: JPEG, PNG, GIF, WebP"))
    }
    
    return errors
}

// Валидация UUID пользователя
fun validateUserId(userId: String?): List<AvatarValidationError> {
    val errors = mutableListOf<AvatarValidationError>()
    
    if (userId.isNullOrBlank()) {
        errors.add(AvatarValidationError("userId", "User ID is required"))
    } else if (!isValidUUID(userId)) {
        errors.add(AvatarValidationError("userId", "User ID must be a valid UUID"))
    }
    
    return errors
}

// Вспомогательные функции для валидации аватарок
private fun isValidAvatarContentType(contentType: String): Boolean {
    val allowedTypes = setOf("image/jpeg", "image/png", "image/gif", "image/webp")
    return allowedTypes.contains(contentType)
}

private fun isValidUUID(uuid: String): Boolean {
    return try {
        java.util.UUID.fromString(uuid)
        true
    } catch (e: IllegalArgumentException) {
        false
    }
}
