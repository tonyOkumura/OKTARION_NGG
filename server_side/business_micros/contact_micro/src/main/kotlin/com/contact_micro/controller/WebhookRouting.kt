package com.contact_micro.controller

import com.contact_micro.model.SupabaseWebhookPayload
import com.contact_micro.model.WebhookResponse
import com.contact_micro.service.WebhookService
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import java.sql.Connection
import org.slf4j.LoggerFactory

fun Route.configureWebhookRouting(dbConnection: Connection) {
    val webhookService = WebhookService(dbConnection)
    val logger = LoggerFactory.getLogger("WebhookRouting")
    
    // Webhook endpoint for Supabase Auth events
    post("/webhook/supabase") {
        try {
            logger.info("Received Supabase webhook")
            
            // Получаем payload от Supabase
            val payload = call.receive<SupabaseWebhookPayload>()
            
            logger.info("Webhook payload: type=${payload.type}, table=${payload.table}")
            
            // Проверяем, что это событие из таблицы auth.users
            if (payload.table != "users" || payload.schema != "auth") {
                logger.warn("Ignoring webhook for table: ${payload.table}.${payload.schema}")
                call.respond(HttpStatusCode.OK, WebhookResponse(
                    success = true,
                    message = "Webhook ignored - not auth.users table"
                ))
                return@post
            }
            
            val user = payload.record ?: run {
                logger.warn("No user record in webhook payload")
                call.respond(HttpStatusCode.BadRequest, WebhookResponse(
                    success = false,
                    message = "No user record in payload"
                ))
                return@post
            }
            
            val response = when (payload.type) {
                "INSERT" -> {
                    logger.info("Processing user registration for: ${user.email}")
                    webhookService.processUserRegistration(user)
                }
                "UPDATE" -> {
                    logger.info("Processing user update for: ${user.email}")
                    // Проверяем, изменился ли статус подтверждения email
                    val oldUser = payload.old_record
                    if (oldUser?.email_confirmed_at != user.email_confirmed_at) {
                        webhookService.processEmailConfirmation(user)
                    } else {
                        WebhookResponse(
                            success = true,
                            message = "No email confirmation change detected"
                        )
                    }
                }
                else -> {
                    logger.info("Ignoring webhook type: ${payload.type}")
                    WebhookResponse(
                        success = true,
                        message = "Webhook type ${payload.type} ignored"
                    )
                }
            }
            
            logger.info("Webhook processing result: ${response.message}")
            
            if (response.success) {
                call.respond(HttpStatusCode.OK, response)
            } else {
                call.respond(HttpStatusCode.BadRequest, response)
            }
            
        } catch (e: Exception) {
            logger.error("Error processing webhook: ${e.message}", e)
            call.respond(HttpStatusCode.InternalServerError, WebhookResponse(
                success = false,
                message = "Internal server error: ${e.message}"
            ))
        }
    }
    
    // Health check endpoint for webhook
    get("/webhook/health") {
        call.respond(HttpStatusCode.OK, mapOf(
            "status" to "healthy",
            "service" to "webhook",
            "timestamp" to System.currentTimeMillis()
        ))
    }
}
