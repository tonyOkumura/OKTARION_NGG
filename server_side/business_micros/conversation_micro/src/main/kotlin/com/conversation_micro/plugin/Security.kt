package com.conversation_micro.plugin

import com.conversation_micro.config.getAppConfig
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.plugins.cors.routing.*
import io.ktor.server.plugins.defaultheaders.*

fun Application.configureSecurity() {
    val config = getAppConfig()
    
    install(DefaultHeaders) {
        header("X-Content-Type-Options", "nosniff")
        header("X-Frame-Options", "DENY")
        header("X-XSS-Protection", "1; mode=block")
        header("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
        header("Referrer-Policy", "strict-origin-when-cross-origin")
    }
    
    if (config.security.enableCors) {
        install(CORS) {
            allowMethod(HttpMethod.Get)
            allowMethod(HttpMethod.Post)
            allowMethod(HttpMethod.Put)
            allowMethod(HttpMethod.Delete)
            allowMethod(HttpMethod.Options)
            
            allowHeader(HttpHeaders.ContentType)
            allowHeader(HttpHeaders.Authorization)
            allowHeader("X-Correlation-ID")
            allowHeader("X-Request-ID")
            
            config.security.corsOrigins.forEach { origin ->
                if (origin == "*") {
                    anyHost()
                } else {
                    allowHost(origin, schemes = listOf("http", "https"))
                }
            }
            
            allowCredentials = true
            maxAgeInSeconds = 24 * 60 * 60 // 24 hours
        }
    }
}

// Request validation is handled in Validation.kt
