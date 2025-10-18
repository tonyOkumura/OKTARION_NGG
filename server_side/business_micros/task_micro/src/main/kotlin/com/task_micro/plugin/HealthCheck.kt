package com.task_micro.plugin

import com.task_micro.config.getAppConfig
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.litote.kmongo.coroutine.coroutine
import org.litote.kmongo.reactivestreams.KMongo
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
    
    // Database check
    try {
        val mongoClient = getDatabaseConnection()
        if (mongoClient != null) {
            checks["database"] = CheckResult("UP", "MongoDB connection successful")
        } else {
            checks["database"] = CheckResult("DOWN", "MongoDB connection failed")
        }
    } catch (e: Exception) {
        checks["database"] = CheckResult("DOWN", "MongoDB error: ${e.message}")
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
    
    // Database readiness
    try {
        val mongoClient = getDatabaseConnection()
        if (mongoClient != null) {
            checks["database"] = CheckResult("UP", "MongoDB is ready")
        } else {
            checks["database"] = CheckResult("DOWN", "MongoDB not ready")
        }
    } catch (e: Exception) {
        checks["database"] = CheckResult("DOWN", "MongoDB not ready: ${e.message}")
    }
    
    return ReadinessStatus(
        status = if (checks.values.all { it.status == "UP" }) "UP" else "DOWN",
        timestamp = System.currentTimeMillis(),
        checks = checks
    )
}

private fun Application.getDatabaseConnection(): org.litote.kmongo.coroutine.CoroutineClient? {
    return try {
        val config = getAppConfig()
        KMongo.createClient(config.database.connectionString).coroutine
    } catch (e: Exception) {
        null
    }
}
