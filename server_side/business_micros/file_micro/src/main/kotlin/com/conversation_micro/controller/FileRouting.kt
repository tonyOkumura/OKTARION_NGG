package com.file_micro.controller

import com.file_micro.model.*
import com.file_micro.service.FileService
import com.file_micro.config.AppConfig
import com.file_micro.plugin.validateFileUpload
import com.file_micro.plugin.validateFileUpdate
import com.file_micro.plugin.respondValidationError
import com.file_micro.plugin.respondInternalError
import com.file_micro.plugin.respondBadRequest
import com.file_micro.plugin.respondNotFound
import com.file_micro.plugin.getUserId
import com.file_micro.plugin.logWithUser
import io.ktor.http.*
import io.ktor.http.content.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.minio.MinioClient
import java.io.InputStream
import java.io.OutputStream

fun Application.configureFileRouting(minioClient: MinioClient, config: AppConfig) {
    val fileService = FileService(minioClient, config.minio)
    
    routing {
        
        // Загрузка файла
        post("/files") {
            try {
                val userId = call.getUserId()
                call.logWithUser("info", "Uploading new file")
                
                val multipartData = call.receiveMultipart()
                var fileName: String? = null
                var contentType: String? = null
                var fileBytes: ByteArray? = null
                val metadata = mutableMapOf<String, String>()
                
                multipartData.forEachPart { part ->
                    when (part) {
                        is PartData.FormItem -> {
                            when (part.name) {
                                "fileName" -> fileName = part.value
                                "contentType" -> contentType = part.value
                                "metadata" -> {
                                    // Простой парсинг метаданных (можно улучшить)
                                    part.value.split(",").forEach { pair ->
                                        val keyValue = pair.split(":")
                                        if (keyValue.size == 2) {
                                            metadata[keyValue[0].trim()] = keyValue[1].trim()
                                        }
                                    }
                                }
                            }
                        }
                        is PartData.FileItem -> {
                            fileName = fileName ?: part.originalFileName ?: "unknown"
                            contentType = contentType ?: part.contentType?.toString()
                            // Используем streamProvider().readBytes() для чтения файла
                            fileBytes = part.streamProvider().readBytes()
                        }
                        else -> {}
                    }
                    part.dispose() // Освобождаем ресурсы
                }
                
                if (fileName == null || fileBytes == null) {
                    call.logWithUser("warn", "Missing file data in upload request")
                    call.respondBadRequest("File data is required")
                    return@post
                }
                
                // Валидация
                val uploadRequest = FileUploadRequest(
                    fileName = fileName!!,
                    contentType = contentType,
                    metadata = metadata
                )
                
                val validationErrors = validateFileUpload(uploadRequest)
                if (validationErrors.isNotEmpty()) {
                    call.logWithUser("warn", "File upload validation failed: ${validationErrors.joinToString { "${it.field}: ${it.message}" }}")
                    call.respondValidationError("Validation failed", validationErrors)
                    return@post
                }
                
                val uploadResponse = fileService.uploadFile(
                    fileBytes = fileBytes!!,
                    fileName = fileName!!,
                    contentType = contentType,
                    uploadedBy = userId ?: throw IllegalArgumentException("Okta-User-ID header is required"),
                    customMetadata = metadata
                )
                
                call.logWithUser("info", "File uploaded successfully: ${uploadResponse.id}")
                call.respond(HttpStatusCode.Created, uploadResponse)
                
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid upload request: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid upload request")
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to upload file: ${e.message}")
                call.respondInternalError("Failed to upload file: ${e.message}")
            }
        }

        // Получение списка файлов
        get("/files") {
            try {
                val userId = call.getUserId()
                val uploadedBy = call.request.queryParameters["uploadedBy"]
                val marker = call.request.queryParameters["marker"]
                val limitParam = call.request.queryParameters["limit"]?.toIntOrNull()
                val limit = if (limitParam != null && limitParam in 1..config.pagination.maxLimit) limitParam else config.pagination.defaultLimit
                
                call.logWithUser("info", "Listing files: uploadedBy=$uploadedBy, marker=$marker, limit=$limit")
                
                val result = fileService.listFiles(
                    uploadedBy = uploadedBy ?: userId,
                    marker = marker,
                    limit = limit
                )
                
                call.logWithUser("info", "Retrieved ${result.files.size} files, hasMore=${result.hasMore}")
                call.respond(HttpStatusCode.OK, result)
                
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to list files: ${e.message}")
                call.respondInternalError("Failed to list files: ${e.message}")
            }
        }

        // Получение информации о файле
        get("/files/{id}") {
            try {
                val userId = call.getUserId()
                val fileId = call.parameters["id"] 
                    ?: throw IllegalArgumentException("File ID is required")
                
                call.logWithUser("info", "Getting file info: $fileId")
                
                val fileInfo = fileService.getFileInfo(fileId)
                call.logWithUser("info", "File info retrieved: ${fileInfo.fileName}")
                call.respond(HttpStatusCode.OK, fileInfo)
                
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid file ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid file ID")
            } catch (e: Exception) {
                if (e.message?.contains("not found") == true) {
                    call.logWithUser("warn", "File not found: ${call.parameters["id"]}")
                    call.respondNotFound("File not found")
                } else {
                    call.logWithUser("error", "Failed to get file info: ${e.message}")
                    call.respondInternalError("Failed to get file info: ${e.message}")
                }
            }
        }

        // Скачивание файла
        get("/files/{id}/download") {
            try {
                val userId = call.getUserId()
                val fileId = call.parameters["id"] 
                    ?: throw IllegalArgumentException("File ID is required")
                
                call.logWithUser("info", "Downloading file: $fileId")
                
                val (inputStream, fileInfo) = fileService.downloadFile(fileId)
                
                call.response.headers.append(HttpHeaders.ContentDisposition, "attachment; filename=\"${fileInfo.fileName}\"")
                fileInfo.contentType?.let { 
                    call.response.headers.append(HttpHeaders.ContentType, it)
                }
                call.response.headers.append(HttpHeaders.ContentLength, fileInfo.size.toString())
                
                call.logWithUser("info", "File download started: ${fileInfo.fileName}")
                
                // Читаем весь файл в байты и отправляем
                val fileBytes = inputStream.readBytes()
                call.respondBytes(fileBytes)
                
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid file ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid file ID")
            } catch (e: Exception) {
                if (e.message?.contains("not found") == true) {
                    call.logWithUser("warn", "File not found for download: ${call.parameters["id"]}")
                    call.respondNotFound("File not found")
                } else {
                    call.logWithUser("error", "Failed to download file: ${e.message}")
                    call.respondInternalError("Failed to download file: ${e.message}")
                }
            }
        }

        // Генерация presigned URL для скачивания
        get("/files/{id}/download-url") {
            try {
                val userId = call.getUserId()
                val fileId = call.parameters["id"] 
                    ?: throw IllegalArgumentException("File ID is required")
                
                call.logWithUser("info", "Generating download URL: $fileId")
                
                val downloadResponse = fileService.generateDownloadUrl(fileId)
                call.logWithUser("info", "Download URL generated: ${downloadResponse.fileName}")
                call.respond(HttpStatusCode.OK, downloadResponse)
                
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid file ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid file ID")
            } catch (e: Exception) {
                if (e.message?.contains("not found") == true) {
                    call.logWithUser("warn", "File not found for URL generation: ${call.parameters["id"]}")
                    call.respondNotFound("File not found")
                } else {
                    call.logWithUser("error", "Failed to generate download URL: ${e.message}")
                    call.respondInternalError("Failed to generate download URL: ${e.message}")
                }
            }
        }

        // Обновление метаданных файла
        put("/files/{id}") {
            try {
                val userId = call.getUserId()
                val fileId = call.parameters["id"] 
                    ?: throw IllegalArgumentException("File ID is required")
                
                call.logWithUser("info", "Updating file metadata: $fileId")
                
                val updateRequest = call.receive<FileUpdateRequest>()
                
                // Валидация
                val validationErrors = validateFileUpdate(updateRequest)
                if (validationErrors.isNotEmpty()) {
                    call.logWithUser("warn", "File update validation failed: ${validationErrors.joinToString { "${it.field}: ${it.message}" }}")
                    call.respondValidationError("Validation failed", validationErrors)
                    return@put
                }
                
                val updatedFileInfo = fileService.updateFileMetadata(fileId, updateRequest)
                call.logWithUser("info", "File metadata updated: ${updatedFileInfo.fileName}")
                call.respond(HttpStatusCode.OK, updatedFileInfo)
                
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid file ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid file ID")
            } catch (e: Exception) {
                if (e.message?.contains("not found") == true) {
                    call.logWithUser("warn", "File not found for update: ${call.parameters["id"]}")
                    call.respondNotFound("File not found")
                } else {
                    call.logWithUser("error", "Failed to update file: ${e.message}")
                    call.respondInternalError("Failed to update file: ${e.message}")
                }
            }
        }

        // Удаление файла
        delete("/files/{id}") {
            try {
                val userId = call.getUserId()
                val fileId = call.parameters["id"] 
                    ?: throw IllegalArgumentException("File ID is required")
                
                call.logWithUser("info", "Deleting file: $fileId")
                
                val deleteResponse = fileService.deleteFile(fileId)
                call.logWithUser("info", "File deleted: ${deleteResponse.fileName}")
                call.respond(HttpStatusCode.OK, deleteResponse)
                
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid file ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid file ID")
            } catch (e: Exception) {
                if (e.message?.contains("not found") == true) {
                    call.logWithUser("warn", "File not found for deletion: ${call.parameters["id"]}")
                    call.respondNotFound("File not found")
                } else {
                    call.logWithUser("error", "Failed to delete file: ${e.message}")
                    call.respondInternalError("Failed to delete file: ${e.message}")
                }
            }
        }
    }
}
