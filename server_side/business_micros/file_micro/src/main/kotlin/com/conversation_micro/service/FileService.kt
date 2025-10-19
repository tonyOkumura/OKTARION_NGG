package com.file_micro.service

import com.file_micro.config.MinIOConfig
import com.file_micro.model.*
import io.minio.*
import io.minio.http.Method
import kotlinx.coroutines.*
import java.io.ByteArrayInputStream
import java.io.InputStream
import java.time.Instant
import java.util.*
import java.util.concurrent.TimeUnit

class FileService(private val minioClient: MinioClient, private val config: MinIOConfig) {
    
    companion object {
        private const val PRESIGNED_URL_EXPIRY_HOURS = 24L
    }

    // Загрузка файла
    suspend fun uploadFile(
        fileBytes: ByteArray,
        fileName: String,
        contentType: String?,
        uploadedBy: String,
        customMetadata: Map<String, String> = emptyMap()
    ): FileUploadResponse = withContext(Dispatchers.IO) {
        val fileId = UUID.randomUUID().toString()
        val timestamp = Instant.now()
        val objectName = generateObjectName(fileId, fileName)
        
        // Подготовка метаданных
        val metadata = mutableMapOf<String, String>().apply {
            put(FileMetadataKeys.FILE_ID, fileId)
            put(FileMetadataKeys.ORIGINAL_FILE_NAME, fileName)
            put(FileMetadataKeys.UPLOADED_BY, uploadedBy)
            put(FileMetadataKeys.UPLOADED_AT, timestamp.toString())
            contentType?.let { put(FileMetadataKeys.CONTENT_TYPE, it) }
            putAll(customMetadata)
        }
        
        // Загрузка в MinIO используя ByteArrayInputStream
        val inputStream = ByteArrayInputStream(fileBytes)
        val putObjectArgs = PutObjectArgs.builder()
            .bucket(config.bucketName)
            .`object`(objectName)
            .stream(inputStream, fileBytes.size.toLong(), -1)
            .contentType(contentType ?: "application/octet-stream")
            .userMetadata(metadata)
            .build()
        
        minioClient.putObject(putObjectArgs)
        
        FileUploadResponse(
            id = fileId,
            fileName = fileName,
            size = fileBytes.size.toLong(),
            contentType = contentType,
            uploadedAt = timestamp.toString()
        )
    }

    // Получение информации о файле
    suspend fun getFileInfo(fileId: String): FileInfo = withContext(Dispatchers.IO) {
        val objectName = findObjectNameByFileId(fileId)
        
        val statObjectArgs = StatObjectArgs.builder()
            .bucket(config.bucketName)
            .`object`(objectName)
            .build()
        
        val stat = minioClient.statObject(statObjectArgs)
        
        FileInfo(
            id = fileId,
            fileName = stat.userMetadata()[FileMetadataKeys.ORIGINAL_FILE_NAME] ?: "unknown",
            originalFileName = stat.userMetadata()[FileMetadataKeys.ORIGINAL_FILE_NAME] ?: "unknown",
            contentType = stat.contentType(),
            size = stat.size(),
            bucketName = config.bucketName,
            objectName = objectName,
            metadata = stat.userMetadata(),
            uploadedBy = stat.userMetadata()[FileMetadataKeys.UPLOADED_BY] ?: "unknown",
            uploadedAt = stat.userMetadata()[FileMetadataKeys.UPLOADED_AT] ?: "unknown",
            lastModified = stat.lastModified().toString(),
            etag = stat.etag()
        )
    }

    // Скачивание файла
    suspend fun downloadFile(fileId: String): Pair<InputStream, FileInfo> = withContext(Dispatchers.IO) {
        val fileInfo = getFileInfo(fileId)
        
        val getObjectArgs = GetObjectArgs.builder()
            .bucket(config.bucketName)
            .`object`(fileInfo.objectName)
            .build()
        
        val inputStream = minioClient.getObject(getObjectArgs)
        Pair(inputStream, fileInfo)
    }

    // Генерация presigned URL для скачивания
    suspend fun generateDownloadUrl(fileId: String): FileDownloadResponse = withContext(Dispatchers.IO) {
        val fileInfo = getFileInfo(fileId)
        
        val presignedUrlArgs = GetPresignedObjectUrlArgs.builder()
            .method(Method.GET)
            .bucket(config.bucketName)
            .`object`(fileInfo.objectName)
            .expiry(PRESIGNED_URL_EXPIRY_HOURS.toInt(), TimeUnit.HOURS)
            .build()
        
        // Генерируем URL с внутренним адресом (подпись будет корректной)
        val downloadUrl = minioClient.getPresignedObjectUrl(presignedUrlArgs)
        
        FileDownloadResponse(
            id = fileId,
            fileName = fileInfo.fileName,
            contentType = fileInfo.contentType,
            size = fileInfo.size,
            downloadUrl = downloadUrl,
            expiresAt = Instant.now().plusSeconds(PRESIGNED_URL_EXPIRY_HOURS * 3600).toString()
        )
    }

    // Обновление метаданных файла
    suspend fun updateFileMetadata(fileId: String, updateRequest: FileUpdateRequest): FileInfo = withContext(Dispatchers.IO) {
        val fileInfo = getFileInfo(fileId)
        
        // MinIO не поддерживает обновление метаданных напрямую
        // Нужно перезагрузить файл с новыми метаданными
        val updatedMetadata = fileInfo.metadata.toMutableMap().apply {
            updateRequest.fileName?.let { put(FileMetadataKeys.ORIGINAL_FILE_NAME, it) }
            updateRequest.metadata?.let { putAll(it) }
        }
        
        // Получаем содержимое файла
        val (inputStream, _) = downloadFile(fileId)
        val fileBytes = inputStream.readBytes()
        
        // Удаляем старый файл
        deleteFile(fileId)
        
        // Загружаем с новыми метаданными
        val uploadResponse = uploadFile(
            fileBytes = fileBytes,
            fileName = updateRequest.fileName ?: fileInfo.fileName,
            contentType = fileInfo.contentType,
            uploadedBy = fileInfo.uploadedBy,
            customMetadata = updateRequest.metadata ?: emptyMap()
        )
        
        getFileInfo(uploadResponse.id)
    }

    // Удаление файла
    suspend fun deleteFile(fileId: String): FileDeleteResponse = withContext(Dispatchers.IO) {
        val fileInfo = getFileInfo(fileId)
        
        val removeObjectArgs = RemoveObjectArgs.builder()
            .bucket(config.bucketName)
            .`object`(fileInfo.objectName)
            .build()
        
        minioClient.removeObject(removeObjectArgs)
        
        FileDeleteResponse(
            id = fileId,
            fileName = fileInfo.fileName,
            deletedAt = Instant.now().toString(),
            message = "File deleted successfully"
        )
    }

    // Получение списка файлов с пагинацией
    suspend fun listFiles(
        uploadedBy: String? = null,
        marker: String? = null,
        limit: Int = 50
    ): FileListResponse = withContext(Dispatchers.IO) {
        val listObjectsArgs = ListObjectsArgs.builder()
            .bucket(config.bucketName)
            .prefix("files/") // Префикс для организации файлов
            .marker(marker)
            .maxKeys((limit + 1).toInt()) // +1 для определения hasMore
            .build()
        
        val objects = minioClient.listObjects(listObjectsArgs)
        val files = mutableListOf<FileInfo>()
        var nextMarker: String? = null
        
        var count = 0
        for (result in objects) {
            if (count >= limit) {
                nextMarker = result.get().objectName()
                break
            }
            
            try {
                val fileInfo = getFileInfoFromObjectName(result.get().objectName())
                if (uploadedBy == null || fileInfo.uploadedBy == uploadedBy) {
                    files.add(fileInfo)
                }
                count++
            } catch (e: Exception) {
                // Пропускаем файлы с некорректными метаданными
                continue
            }
        }
        
        FileListResponse(
            files = files,
            hasMore = nextMarker != null,
            nextMarker = nextMarker
        )
    }

    // Вспомогательные методы
    private fun generateObjectName(fileId: String, fileName: String): String {
        val timestamp = Instant.now().epochSecond
        return "files/$timestamp-$fileId-$fileName"
    }

    private suspend fun findObjectNameByFileId(fileId: String): String = withContext(Dispatchers.IO) {
        val listObjectsArgs = ListObjectsArgs.builder()
            .bucket(config.bucketName)
            .prefix("files/")
            .build()
        
        val objects = minioClient.listObjects(listObjectsArgs)
        
        for (result in objects) {
            val objectName = result.get().objectName()
            if (objectName.contains(fileId)) {
                return@withContext objectName
            }
        }
        
        throw Exception("File with ID $fileId not found")
    }

    private suspend fun getFileInfoFromObjectName(objectName: String): FileInfo = withContext(Dispatchers.IO) {
        val statObjectArgs = StatObjectArgs.builder()
            .bucket(config.bucketName)
            .`object`(objectName)
            .build()
        
        val stat = minioClient.statObject(statObjectArgs)
        val metadata = stat.userMetadata()
        
        FileInfo(
            id = metadata[FileMetadataKeys.FILE_ID] ?: "unknown",
            fileName = metadata[FileMetadataKeys.ORIGINAL_FILE_NAME] ?: "unknown",
            originalFileName = metadata[FileMetadataKeys.ORIGINAL_FILE_NAME] ?: "unknown",
            contentType = stat.contentType(),
            size = stat.size(),
            bucketName = config.bucketName,
            objectName = objectName,
            metadata = metadata,
            uploadedBy = metadata[FileMetadataKeys.UPLOADED_BY] ?: "unknown",
            uploadedAt = metadata[FileMetadataKeys.UPLOADED_AT] ?: "unknown",
            lastModified = stat.lastModified().toString(),
            etag = stat.etag()
        )
    }
}
