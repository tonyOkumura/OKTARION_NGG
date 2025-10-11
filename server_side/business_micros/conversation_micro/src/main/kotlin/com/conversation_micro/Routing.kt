package com.conversation_micro

import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun Application.configureRouting() {
    routing {
        get("/") {
            call.respondText("Hello World!")
        }
        
        // Обработка CORS preflight запросов
        options {
            call.respond(HttpStatusCode.OK)
        }
    }
}
