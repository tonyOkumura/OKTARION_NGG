package com.example

import com.example.config.getAppConfig
import com.example.plugin.configureLogging
import com.example.plugin.configureSecurity
import com.example.plugin.configureSerialization
import com.example.plugin.configureValidation
import com.example.plugin.configureGracefulShutdown
import com.example.plugin.configureErrorHandling
import com.example.infrastructure.configureDatabases
import com.example.plugin.configureHealthCheck
import com.example.configureRouting
import com.example.configureFrameworks
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
