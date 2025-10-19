package com.file_micro

import com.file_micro.config.getAppConfig
import com.file_micro.plugin.configureLogging
import com.file_micro.plugin.configureSecurity
import com.file_micro.plugin.configureSerialization
import com.file_micro.plugin.configureValidation
import com.file_micro.plugin.configureGracefulShutdown
import com.file_micro.plugin.configureUserAuthentication
import com.file_micro.infrastructure.configureMinIO
import com.file_micro.plugin.configureErrorHandling
import com.file_micro.plugin.configureHealthCheck
import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*

fun main() {
    // Используем значения по умолчанию для main()
    val port = System.getenv("SERVER_PORT")?.toIntOrNull() ?: 8060
    val host = System.getenv("SERVER_HOST") ?: "0.0.0.0"
    
    embeddedServer(Netty, port = port, host = host, module = Application::module)
        .start(wait = true)
}

fun Application.module() {
   
    // Configure core components
    configureLogging()
    configureSecurity()
    configureUserAuthentication()
    configureSerialization()
    configureValidation()
    configureErrorHandling()
    configureGracefulShutdown()
    
    // Configure MinIO storage
    configureMinIO()
    configureHealthCheck()
    configureRouting()
    
    // Configure frameworks
    configureFrameworks()
}
