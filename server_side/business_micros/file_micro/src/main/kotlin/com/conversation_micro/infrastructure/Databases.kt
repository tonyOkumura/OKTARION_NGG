package com.file_micro.infrastructure

import com.file_micro.config.getAppConfig
import com.file_micro.controller.configureFileRouting
import com.file_micro.controller.configureAvatarRouting
import io.ktor.server.application.*
import io.minio.MinioClient

fun Application.configureMinIO() {
    val config = getAppConfig()
    
    // Создаем клиент MinIO
    val minioClient = MinioClient.builder()
        .endpoint(config.minio.endpoint)
        .credentials(config.minio.accessKey, config.minio.secretKey)
        .build()
    
    // Проверяем подключение и создаем bucket если нужно
    try {
        val bucketExists = minioClient.bucketExists(
            io.minio.BucketExistsArgs.builder()
                .bucket(config.minio.bucketName)
                .build()
        )
        
        if (!bucketExists) {
            minioClient.makeBucket(
                io.minio.MakeBucketArgs.builder()
                    .bucket(config.minio.bucketName)
                    .region(config.minio.region)
                    .build()
            )
            log.info("Created MinIO bucket: ${config.minio.bucketName}")
        } else {
            log.info("MinIO bucket already exists: ${config.minio.bucketName}")
        }
        
        log.info("Connected to MinIO at ${config.minio.endpoint}")
        
        // Настраиваем маршрутизацию для файлов и аватарок
        configureFileRouting(minioClient, config)
        configureAvatarRouting(minioClient, config)
        
    } catch (e: Exception) {
        log.error("Failed to connect to MinIO: ${e.message}", e)
        throw e
    }
}
