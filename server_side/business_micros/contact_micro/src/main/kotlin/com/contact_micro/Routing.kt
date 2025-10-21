package com.contact_micro

import com.contact_micro.controller.configureWebhookRouting
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import java.sql.Connection

fun Application.configureMainRouting(dbConnection: Connection) {
    routing {
        // Обработка CORS preflight запросов
        options {
            call.respond(HttpStatusCode.OK)
        }
    }
}
