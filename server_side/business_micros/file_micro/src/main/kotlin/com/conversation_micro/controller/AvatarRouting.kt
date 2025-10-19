package com.file_micro.controller

import com.file_micro.model.*
import com.file_micro.service.AvatarService
import com.file_micro.config.AppConfig
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

fun Application.configureAvatarRouting(minioClient: MinioClient, config: AppConfig) {
    val avatarService = AvatarService(minioClient, config.minio)
    
    routing {
        
        // Загрузка аватарки пользователя
        post("/avatars") {
            try {
                val userId = call.getUserId()
                    ?: throw IllegalArgumentException("Okta-User-ID header is required")
                
                call.logWithUser("info", "Uploading avatar for user: $userId")
                
                val multipartData = call.receiveMultipart()
                var contentType: String? = null
                var fileBytes: ByteArray? = null
                
                multipartData.forEachPart { part ->
                    when (part) {
                        is PartData.FormItem -> {
                            when (part.name) {
                                "contentType" -> contentType = part.value
                            }
                        }
                        is PartData.FileItem -> {
                            contentType = contentType ?: part.contentType?.toString()
                            fileBytes = part.streamProvider().readBytes()
                        }
                        else -> {}
                    }
                    part.dispose()
                }
                
                if (fileBytes == null) {
                    call.logWithUser("warn", "Missing avatar data in upload request")
                    call.respondBadRequest("Avatar data is required")
                    return@post
                }
                
                val uploadResponse = avatarService.uploadAvatar(
                    fileBytes = fileBytes!!,
                    userId = userId,
                    contentType = contentType
                )
                
                call.logWithUser("info", "Avatar uploaded successfully for user: $userId")
                call.respond(HttpStatusCode.Created, uploadResponse)
                
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid avatar upload request: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid avatar upload request")
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to upload avatar: ${e.message}")
                call.respondInternalError("Failed to upload avatar: ${e.message}")
            }
        }

        // Получение информации об аватарке пользователя
        get("/avatars/{userId}") {
            try {
                val currentUserId = call.getUserId()
                val targetUserId = call.parameters["userId"]
                    ?: throw IllegalArgumentException("User ID is required")
                
                call.logWithUser("info", "Getting avatar info for user: $targetUserId")
                
                val avatarInfo = avatarService.getAvatarInfo(targetUserId)
                call.logWithUser("info", "Avatar info retrieved for user: $targetUserId")
                call.respond(HttpStatusCode.OK, avatarInfo)
                
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid user ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid user ID")
            } catch (e: Exception) {
                if (e.message?.contains("not found") == true) {
                    call.logWithUser("warn", "Avatar not found for user: ${call.parameters["userId"]}")
                    call.respondNotFound("Avatar not found")
                } else {
                    call.logWithUser("error", "Failed to get avatar info: ${e.message}")
                    call.respondInternalError("Failed to get avatar info: ${e.message}")
                }
            }
        }

        // Скачивание аватарки пользователя
        get("/avatars/{userId}/download") {
            try {
                val currentUserId = call.getUserId()
                val targetUserId = call.parameters["userId"]
                    ?: throw IllegalArgumentException("User ID is required")
                
                call.logWithUser("info", "Downloading avatar for user: $targetUserId")
                
                val (inputStream, avatarInfo) = avatarService.downloadAvatar(targetUserId)
                
                call.response.headers.append(HttpHeaders.ContentDisposition, "inline; filename=\"avatar_${targetUserId}\"")
                avatarInfo.contentType?.let { 
                    call.response.headers.append(HttpHeaders.ContentType, it)
                }
                call.response.headers.append(HttpHeaders.ContentLength, avatarInfo.size.toString())
                
                call.logWithUser("info", "Avatar download started for user: $targetUserId")
                
                val fileBytes = inputStream.readBytes()
                call.respondBytes(fileBytes)
                
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid user ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid user ID")
            } catch (e: Exception) {
                if (e.message?.contains("not found") == true) {
                    call.logWithUser("warn", "Avatar not found for download: ${call.parameters["userId"]}")
                    call.respondNotFound("Avatar not found")
                } else {
                    call.logWithUser("error", "Failed to download avatar: ${e.message}")
                    call.respondInternalError("Failed to download avatar: ${e.message}")
                }
            }
        }

        // Генерация presigned URL для скачивания аватарки
        get("/avatars/{userId}/download-url") {
            try {
                val currentUserId = call.getUserId()
                val targetUserId = call.parameters["userId"]
                    ?: throw IllegalArgumentException("User ID is required")
                
                call.logWithUser("info", "Generating download URL for avatar: $targetUserId")
                
                val downloadResponse = avatarService.generateAvatarDownloadUrl(targetUserId)
                call.logWithUser("info", "Download URL generated for user: $targetUserId")
                call.respond(HttpStatusCode.OK, downloadResponse)
                
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid user ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid user ID")
            } catch (e: Exception) {
                if (e.message?.contains("not found") == true) {
                    call.logWithUser("warn", "Avatar not found for URL generation: ${call.parameters["userId"]}")
                    call.respondNotFound("Avatar not found")
                } else {
                    call.logWithUser("error", "Failed to generate download URL: ${e.message}")
                    call.respondInternalError("Failed to generate download URL: ${e.message}")
                }
            }
        }

        // Удаление аватарки пользователя (только свою)
        delete("/avatars") {
            try {
                val userId = call.getUserId()
                    ?: throw IllegalArgumentException("Okta-User-ID header is required")
                
                call.logWithUser("info", "Deleting avatar for user: $userId")
                
                val deleteResponse = avatarService.deleteAvatar(userId)
                call.logWithUser("info", "Avatar deleted for user: $userId")
                call.respond(HttpStatusCode.OK, deleteResponse)
                
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid user ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid user ID")
            } catch (e: Exception) {
                if (e.message?.contains("not found") == true) {
                    call.logWithUser("warn", "Avatar not found for deletion")
                    call.respondNotFound("Avatar not found")
                } else {
                    call.logWithUser("error", "Failed to delete avatar: ${e.message}")
                    call.respondInternalError("Failed to delete avatar: ${e.message}")
                }
            }
        }

        // Проверка существования аватарки пользователя
        get("/avatars/{userId}/exists") {
            try {
                val currentUserId = call.getUserId()
                val targetUserId = call.parameters["userId"]
                    ?: throw IllegalArgumentException("User ID is required")
                
                call.logWithUser("info", "Checking avatar existence for user: $targetUserId")
                
                val exists = avatarService.avatarExists(targetUserId)
                call.logWithUser("info", "Avatar exists check completed for user: $targetUserId, exists: $exists")
                call.respond(HttpStatusCode.OK, AvatarExistsResponse(targetUserId, exists))
                
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid user ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid user ID")
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to check avatar existence: ${e.message}")
                call.respondInternalError("Failed to check avatar existence: ${e.message}")
            }
        }
    }
}
