package com.file_micro.plugin

import com.file_micro.config.getAppConfig
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.serialization.Serializable

fun Application.configureHealthCheck() {
    routing {
        get("/health") {
            val healthStatus = checkHealth()
            val statusCode = if (healthStatus.isHealthy) HttpStatusCode.OK else HttpStatusCode.ServiceUnavailable
            call.respond(statusCode, healthStatus)
        }
        
        get("/health/ready") {
            val readinessStatus = checkReadiness()
            val statusCode = if (readinessStatus.isReady) HttpStatusCode.OK else HttpStatusCode.ServiceUnavailable
            call.respond(statusCode, readinessStatus)
        }
        
        get("/health/live") {
            val liveStatus = LiveStatus("alive", System.currentTimeMillis())
            call.respond(HttpStatusCode.OK, liveStatus)
        }
    }
}

@Serializable
data class HealthStatus(
    val status: String,
    val timestamp: Long,
    val checks: Map<String, CheckResult>
) {
    val isHealthy: Boolean get() = checks.values.all { it.status == "UP" }
}

@Serializable
data class ReadinessStatus(
    val status: String,
    val timestamp: Long,
    val checks: Map<String, CheckResult>
) {
    val isReady: Boolean get() = checks.values.all { it.status == "UP" }
}

@Serializable
data class LiveStatus(
    val status: String,
    val timestamp: Long
)

@Serializable
data class CheckResult(
    val status: String,
    val details: String? = null
)

private fun Application.checkHealth(): HealthStatus {
    val checks = mutableMapOf<String, CheckResult>()
    
    // MinIO check
    try {
        val minioClient = getMinioClient()
        if (minioClient != null) {
            minioClient.listBuckets()
            checks["minio"] = CheckResult("UP", "MinIO connection successful")
        } else {
            checks["minio"] = CheckResult("DOWN", "MinIO connection failed")
        }
    } catch (e: Exception) {
        checks["minio"] = CheckResult("DOWN", "MinIO error: ${e.message}")
    }
    
    // Application check
    checks["application"] = CheckResult("UP", "Application is running")
    
    return HealthStatus(
        status = if (checks.values.all { it.status == "UP" }) "UP" else "DOWN",
        timestamp = System.currentTimeMillis(),
        checks = checks
    )
}

private fun Application.checkReadiness(): ReadinessStatus {
    val checks = mutableMapOf<String, CheckResult>()
    
    // MinIO readiness
    try {
        val minioClient = getMinioClient()
        if (minioClient != null) {
            minioClient.listBuckets()
            checks["minio"] = CheckResult("UP", "MinIO is ready")
        } else {
            checks["minio"] = CheckResult("DOWN", "MinIO not ready")
        }
    } catch (e: Exception) {
        checks["minio"] = CheckResult("DOWN", "MinIO not ready: ${e.message}")
    }
    
    return ReadinessStatus(
        status = if (checks.values.all { it.status == "UP" }) "UP" else "DOWN",
        timestamp = System.currentTimeMillis(),
        checks = checks
    )
}

private fun Application.getMinioClient(): io.minio.MinioClient? {
    return try {
        val config = getAppConfig()
        io.minio.MinioClient.builder()
            .endpoint(config.minio.endpoint)
            .credentials(config.minio.accessKey, config.minio.secretKey)
            .build()
    } catch (e: Exception) {
        null
    }
}
