package com.conversation_micro.plugin

import com.conversation_micro.config.getAppConfig
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import java.sql.Connection
import java.sql.DriverManager
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
        val dbConnection = getDatabaseConnection()
        if (dbConnection != null && !dbConnection.isClosed) {
            val statement = dbConnection.createStatement()
            statement.executeQuery("SELECT 1")
            checks["database"] = CheckResult("UP", "Database connection successful")
        } else {
            checks["database"] = CheckResult("DOWN", "Database connection failed")
        }
    } catch (e: Exception) {
        checks["database"] = CheckResult("DOWN", "Database error: ${e.message}")
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
        val dbConnection = getDatabaseConnection()
        if (dbConnection != null && !dbConnection.isClosed) {
            val statement = dbConnection.createStatement()
            statement.executeQuery("SELECT 1")
            checks["database"] = CheckResult("UP", "Database is ready")
        } else {
            checks["database"] = CheckResult("DOWN", "Database not ready")
        }
    } catch (e: Exception) {
        checks["database"] = CheckResult("DOWN", "Database not ready: ${e.message}")
    }
    
    return ReadinessStatus(
        status = if (checks.values.all { it.status == "UP" }) "UP" else "DOWN",
        timestamp = System.currentTimeMillis(),
        checks = checks
    )
}

private fun Application.getDatabaseConnection(): Connection? {
    return try {
        val config = getAppConfig()
        DriverManager.getConnection(config.database.url, config.database.user, config.database.password)
    } catch (e: Exception) {
        null
    }
}
