package com.message_micro

import com.message_micro.config.getAppConfig
import com.message_micro.plugin.configureLogging
import com.message_micro.plugin.configureSecurity
import com.message_micro.plugin.configureSerialization
import com.message_micro.plugin.configureValidation
import com.message_micro.plugin.configureGracefulShutdown
import com.message_micro.plugin.configureUserAuthentication
import com.message_micro.infrastructure.configureDatabases
import com.message_micro.plugin.configureErrorHandling
import com.message_micro.plugin.configureHealthCheck
import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*

fun main() {
    // Используем значения по умолчанию для main()
    val port = System.getenv("SERVER_PORT")?.toIntOrNull() ?: 8040
    val host = System.getenv("SERVER_HOST") ?: "0.0.0.0"
    
    embeddedServer(Netty, port = port, host = host, module = Application::module)
        .start(wait = true)
}

fun Application.module() {
    
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
