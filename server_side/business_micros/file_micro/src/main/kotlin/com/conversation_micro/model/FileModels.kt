package com.file_micro.model

import kotlinx.serialization.Serializable
import java.time.Instant

@Serializable
data class FileUploadRequest(
    val fileName: String,
    val contentType: String? = null,
    val metadata: Map<String, String> = emptyMap()
)

@Serializable
data class FileInfo(
    val id: String,
    val fileName: String,
    val originalFileName: String,
    val contentType: String?,
    val size: Long,
    val bucketName: String,
    val objectName: String,
    val metadata: Map<String, String>,
    val uploadedBy: String,
    val uploadedAt: String,
    val lastModified: String,
    val etag: String?
)

@Serializable
data class FileListResponse(
    val files: List<FileInfo>,
    val hasMore: Boolean,
    val nextMarker: String?
)

@Serializable
data class FileUpdateRequest(
    val fileName: String? = null,
    val metadata: Map<String, String>? = null
)

@Serializable
data class FileUploadResponse(
    val id: String,
    val fileName: String,
    val size: Long,
    val contentType: String?,
    val uploadedAt: String,
    val downloadUrl: String? = null
)

@Serializable
data class FileDownloadResponse(
    val id: String,
    val fileName: String,
    val contentType: String?,
    val size: Long,
    val downloadUrl: String,
    val expiresAt: String? = null
)

@Serializable
data class FileDeleteResponse(
    val id: String,
    val fileName: String,
    val deletedAt: String,
    val message: String
)

// Вспомогательные классы для работы с MinIO
data class FileMetadata(
    val id: String,
    val originalFileName: String,
    val uploadedBy: String,
    val uploadedAt: Instant,
    val customMetadata: Map<String, String> = emptyMap()
)

// Константы для метаданных
object FileMetadataKeys {
    const val FILE_ID = "file-id"
    const val ORIGINAL_FILE_NAME = "original-file-name"
    const val UPLOADED_BY = "uploaded-by"
    const val UPLOADED_AT = "uploaded-at"
    const val CONTENT_TYPE = "content-type"
}
