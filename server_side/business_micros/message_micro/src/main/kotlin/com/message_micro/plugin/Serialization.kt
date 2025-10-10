package com.example.message.plugin

import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.application.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.serialization.json.*

fun Application.configureSerialization() {
    install(ContentNegotiation) {
        json()
    }
    
    routing {
        get("/json/kotlinx-serialization") {
            call.respond(mapOf("hello" to "world"))
        }
    }
}
