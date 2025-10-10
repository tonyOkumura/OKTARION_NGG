package com.event_micro.plugin

import com.event_micro.config.getAppConfig
import io.ktor.server.application.*
import io.ktor.server.plugins.calllogging.*
import io.ktor.server.request.*
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.slf4j.MDC
import org.slf4j.event.Level
import java.util.*

fun Application.configureLogging() {
    val config = getAppConfig()
    
    install(CallLogging) {
        level = Level.valueOf(config.logging.level)
        format { call ->
            val correlationId = call.request.header("X-Correlation-ID") ?: generateCorrelationId()
            MDC.put("correlationId", correlationId)
            
            val status = call.response.status()
            val httpMethod = call.request.httpMethod.value
            val uri = call.request.uri
            val userAgent = call.request.header("User-Agent") ?: "unknown"
            val clientIp = call.request.header("X-Forwarded-For") ?: "unknown"
            
            "$httpMethod $uri - $status - $userAgent - $clientIp"
        }
    }
}

fun generateCorrelationId(): String {
    return UUID.randomUUID().toString().substring(0, 8)
}

fun Application.logger(): Logger {
    return LoggerFactory.getLogger("com.event_micro.${this::class.simpleName}")
}

// Extension functions for structured logging
fun Application.logInfo(message: String, vararg args: Any?) {
    logger().info(message, *args)
}

fun Application.logWarn(message: String, vararg args: Any?) {
    logger().warn(message, *args)
}

fun Application.logError(message: String, throwable: Throwable? = null, vararg args: Any?) {
    if (throwable != null) {
        logger().error(message, throwable, *args)
    } else {
        logger().error(message, *args)
    }
}

fun Application.logDebug(message: String, vararg args: Any?) {
    logger().debug(message, *args)
}
