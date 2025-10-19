package com.file_micro.model

import kotlinx.serialization.Serializable
import java.time.Instant

// Запрос на загрузку аватарки
@Serializable
data class AvatarUploadRequest(
    val contentType: String? = null
)

// Ответ после загрузки аватарки
@Serializable
data class AvatarUploadResponse(
    val userId: String,
    val fileName: String,
    val size: Long,
    val contentType: String?,
    val uploadedAt: String,
    val downloadUrl: String? = null
)

// Информация об аватарке
@Serializable
data class AvatarInfo(
    val userId: String,
    val fileName: String,
    val contentType: String?,
    val size: Long,
    val bucketName: String,
    val objectName: String,
    val uploadedAt: String,
    val lastModified: String,
    val etag: String
)

// Ответ для скачивания аватарки
@Serializable
data class AvatarDownloadResponse(
    val userId: String,
    val fileName: String,
    val contentType: String?,
    val size: Long,
    val downloadUrl: String,
    val expiresAt: String
)

// Ответ после удаления аватарки
@Serializable
data class AvatarDeleteResponse(
    val userId: String,
    val fileName: String,
    val deletedAt: String,
    val message: String
)

// Ответ для проверки существования аватарки
@Serializable
data class AvatarExistsResponse(
    val userId: String,
    val exists: Boolean
)

// Ключи для метаданных аватарок в MinIO
object AvatarMetadataKeys {
    const val USER_ID = "user-id"
    const val AVATAR_TYPE = "avatar-type"
    const val UPLOADED_AT = "uploaded-at"
    const val CONTENT_TYPE = "content-type"
}

// Модель для ошибок валидации аватарок
@Serializable
data class AvatarValidationError(val field: String, val message: String)

@Serializable
data class AvatarValidationErrorResponse(
    val message: String,
    val errors: List<AvatarValidationError>,
    val timestamp: Long = Instant.now().toEpochMilli(),
    val path: String? = null,
    val correlationId: String? = null
)
