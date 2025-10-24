package com.contact_micro

import com.contact_micro.config.getAppConfig
import com.contact_micro.plugin.configureLogging
import com.contact_micro.plugin.configureSecurity
import com.contact_micro.plugin.configureSerialization
import com.contact_micro.plugin.configureValidation
import com.contact_micro.plugin.configureGracefulShutdown
import com.contact_micro.plugin.configureUserAuthentication
import com.contact_micro.infrastructure.configureDatabases
import com.contact_micro.plugin.configureErrorHandling
import com.contact_micro.plugin.configureHealthCheck
import com.contact_micro.controller.configureWebhookRouting
import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.routing.*

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
    val config = getAppConfig()
    val dbConnection = configureDatabases()
    configureHealthCheck()
    
    // Configure webhook routing in separate module (no authentication)
    routing {
        configureWebhookRouting(dbConnection, config.avatar)
    }
    
    // Configure authentication for main routes
    configureUserAuthentication()
    
    // Configure main routing AFTER authentication
    configureMainRouting(dbConnection)
    
    // Configure frameworks
    configureFrameworks()
}
