package com.task_micro

import com.task_micro.config.getAppConfig
import com.task_micro.plugin.configureLogging
import com.task_micro.plugin.configureSecurity
import com.task_micro.plugin.configureSerialization
import com.task_micro.plugin.configureValidation
import com.task_micro.plugin.configureGracefulShutdown
import com.task_micro.plugin.configureErrorHandling
import com.task_micro.infrastructure.configureDatabases
import com.task_micro.plugin.configureHealthCheck
import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*

fun main() {
    val config = System.getProperty("app.config") ?: "application.conf"
    // Используем значения по умолчанию для main()
    val port = System.getenv("SERVER_PORT")?.toIntOrNull() ?: 8040
    val host = System.getenv("SERVER_HOST") ?: "0.0.0.0"
    
    embeddedServer(Netty, port = port, host = host, module = Application::module)
        .start(wait = true)
}

fun Application.module() {
    // Load configuration
    val appConfig = getAppConfig()
    
    // Configure core components
    configureLogging()
    configureSecurity()
    configureSerialization()
    configureValidation()
    configureErrorHandling()
    configureGracefulShutdown()
    
    // Configure business logic
    configureDatabases()
    configureHealthCheck()
    configureRouting()
    
    // Configure frameworks
    configureFrameworks()
}
