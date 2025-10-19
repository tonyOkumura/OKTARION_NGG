package com.file_micro.service

import com.file_micro.config.MinIOConfig
import com.file_micro.model.*
import io.minio.*
import io.minio.http.Method
import kotlinx.coroutines.*
import java.io.ByteArrayInputStream
import java.io.InputStream
import java.time.Instant
import java.util.concurrent.TimeUnit

class AvatarService(private val minioClient: MinioClient, private val config: MinIOConfig) {
    
    companion object {
        private const val PRESIGNED_URL_EXPIRY_HOURS = 24L
        private const val AVATAR_PREFIX = "avatars/"
        private const val MAX_AVATAR_SIZE = 5 * 1024 * 1024 // 5MB
        private val ALLOWED_CONTENT_TYPES = setOf("image/jpeg", "image/png", "image/gif", "image/webp")
    }

    // Загрузка аватарки пользователя (заменяет старую если есть)
    suspend fun uploadAvatar(
        fileBytes: ByteArray,
        userId: String,
        contentType: String?
    ): AvatarUploadResponse = withContext(Dispatchers.IO) {
        // Проверяем размер файла
        if (fileBytes.size > MAX_AVATAR_SIZE) {
            throw IllegalArgumentException("Avatar size cannot exceed 5MB")
        }
        
        // Проверяем тип файла
        if (contentType != null && !ALLOWED_CONTENT_TYPES.contains(contentType)) {
            throw IllegalArgumentException("Only image files are allowed for avatars")
        }
        
        // Удаляем старую аватарку если есть
        try {
            deleteAvatar(userId)
        } catch (e: Exception) {
            // Игнорируем ошибки если аватарки не было
        }
        
        val timestamp = Instant.now()
        val objectName = generateAvatarObjectName(userId, contentType)
        
        // Подготовка метаданных
        val metadata = mutableMapOf<String, String>().apply {
            put(AvatarMetadataKeys.USER_ID, userId)
            put(AvatarMetadataKeys.AVATAR_TYPE, "user-avatar")
            put(AvatarMetadataKeys.UPLOADED_AT, timestamp.toString())
            contentType?.let { put(AvatarMetadataKeys.CONTENT_TYPE, it) }
        }
        
        // Загрузка в MinIO
        val inputStream = ByteArrayInputStream(fileBytes)
        val putObjectArgs = PutObjectArgs.builder()
            .bucket(config.bucketName)
            .`object`(objectName)
            .stream(inputStream, fileBytes.size.toLong(), -1)
            .contentType(contentType ?: "image/jpeg")
            .userMetadata(metadata)
            .build()
        
        minioClient.putObject(putObjectArgs)
        
        AvatarUploadResponse(
            userId = userId,
            fileName = "avatar_${userId}",
            size = fileBytes.size.toLong(),
            contentType = contentType,
            uploadedAt = timestamp.toString()
        )
    }

    // Получение информации об аватарке пользователя
    suspend fun getAvatarInfo(userId: String): AvatarInfo = withContext(Dispatchers.IO) {
        val objectName = findAvatarObjectNameByUserId(userId)
        
        val statObjectArgs = StatObjectArgs.builder()
            .bucket(config.bucketName)
            .`object`(objectName)
            .build()
        
        val stat = minioClient.statObject(statObjectArgs)
        val metadata = stat.userMetadata()
        
        AvatarInfo(
            userId = userId,
            fileName = "avatar_${userId}",
            contentType = stat.contentType(),
            size = stat.size(),
            bucketName = config.bucketName,
            objectName = objectName,
            uploadedAt = metadata[AvatarMetadataKeys.UPLOADED_AT] ?: "unknown",
            lastModified = stat.lastModified().toString(),
            etag = stat.etag()
        )
    }

    // Скачивание аватарки пользователя
    suspend fun downloadAvatar(userId: String): Pair<InputStream, AvatarInfo> = withContext(Dispatchers.IO) {
        val avatarInfo = getAvatarInfo(userId)
        
        val getObjectArgs = GetObjectArgs.builder()
            .bucket(config.bucketName)
            .`object`(avatarInfo.objectName)
            .build()
        
        val inputStream = minioClient.getObject(getObjectArgs)
        Pair(inputStream, avatarInfo)
    }

    // Генерация presigned URL для скачивания аватарки
    suspend fun generateAvatarDownloadUrl(userId: String): AvatarDownloadResponse = withContext(Dispatchers.IO) {
        val avatarInfo = getAvatarInfo(userId)
        
        val presignedUrlArgs = GetPresignedObjectUrlArgs.builder()
            .method(Method.GET)
            .bucket(config.bucketName)
            .`object`(avatarInfo.objectName)
            .expiry(PRESIGNED_URL_EXPIRY_HOURS.toInt(), TimeUnit.HOURS)
            .build()
        
        val downloadUrl = minioClient.getPresignedObjectUrl(presignedUrlArgs)
        
        AvatarDownloadResponse(
            userId = userId,
            fileName = avatarInfo.fileName,
            contentType = avatarInfo.contentType,
            size = avatarInfo.size,
            downloadUrl = downloadUrl,
            expiresAt = Instant.now().plusSeconds(PRESIGNED_URL_EXPIRY_HOURS * 3600).toString()
        )
    }

    // Удаление аватарки пользователя
    suspend fun deleteAvatar(userId: String): AvatarDeleteResponse = withContext(Dispatchers.IO) {
        val avatarInfo = getAvatarInfo(userId)
        
        val removeObjectArgs = RemoveObjectArgs.builder()
            .bucket(config.bucketName)
            .`object`(avatarInfo.objectName)
            .build()
        
        minioClient.removeObject(removeObjectArgs)
        
        AvatarDeleteResponse(
            userId = userId,
            fileName = avatarInfo.fileName,
            deletedAt = Instant.now().toString(),
            message = "Avatar deleted successfully"
        )
    }

    // Проверка существования аватарки
    suspend fun avatarExists(userId: String): Boolean = withContext(Dispatchers.IO) {
        try {
            findAvatarObjectNameByUserId(userId)
            true
        } catch (e: Exception) {
            false
        }
    }

    // Вспомогательные методы
    private fun generateAvatarObjectName(userId: String, contentType: String?): String {
        val timestamp = Instant.now().epochSecond
        val extension = when (contentType) {
            "image/jpeg" -> "jpg"
            "image/png" -> "png"
            "image/gif" -> "gif"
            "image/webp" -> "webp"
            else -> "jpg"
        }
        return "${AVATAR_PREFIX}${userId}_${timestamp}.${extension}"
    }

    private suspend fun findAvatarObjectNameByUserId(userId: String): String = withContext(Dispatchers.IO) {
        val listObjectsArgs = ListObjectsArgs.builder()
            .bucket(config.bucketName)
            .prefix(AVATAR_PREFIX)
            .build()
        
        val objects = minioClient.listObjects(listObjectsArgs)
        
        for (result in objects) {
            val objectName = result.get().objectName()
            if (objectName.startsWith("${AVATAR_PREFIX}${userId}_")) {
                return@withContext objectName
            }
        }
        
        throw Exception("Avatar for user $userId not found")
    }
}
