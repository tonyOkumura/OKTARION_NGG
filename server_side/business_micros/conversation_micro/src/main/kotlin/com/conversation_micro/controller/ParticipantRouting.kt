package com.conversation_micro.controller

import com.conversation_micro.model.ParticipantCreateRequest
import com.conversation_micro.model.ParticipantUpdateRequest
import com.conversation_micro.model.ParticipantService
import com.conversation_micro.plugin.validateParticipantCreate
import com.conversation_micro.plugin.validateParticipantUpdate
import com.conversation_micro.plugin.respondValidationError
import com.conversation_micro.plugin.respondInternalError
import com.conversation_micro.plugin.respondBadRequest
import com.conversation_micro.plugin.respondNotFound
import com.conversation_micro.plugin.getUserId
import com.conversation_micro.plugin.logWithUser
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import java.sql.Connection

fun Application.configureParticipantRouting(dbConnection: Connection) {
    val participantService = ParticipantService(dbConnection)
    
    routing {
   
        // Create participant
        post("/conversations/{conversationId}/participants") {
            try {
                val userId = call.getUserId()
                val conversationId = call.parameters["conversationId"] 
                    ?: throw IllegalArgumentException("Conversation ID is required")
                
                call.logWithUser("info", "Adding participant to conversation: $conversationId")
                
                val participant = call.receive<ParticipantCreateRequest>()
                
                // Валидация
                val validationErrors = validateParticipantCreate(participant)
                if (validationErrors.isNotEmpty()) {
                    call.logWithUser("warn", "Participant validation failed: ${validationErrors.joinToString { "${it.field}: ${it.message}" }}")
                    call.respondValidationError("Validation failed", validationErrors)
                    return@post
                }
                
                // Ensure conversationId matches the URL parameter
                val participantRequest = participant.copy(conversationId = conversationId)
                
                val createdParticipant = participantService.create(participantRequest, userId ?: throw IllegalArgumentException("Okta-User-ID header is required"))
                call.logWithUser("info", "Participant added successfully: ${createdParticipant.contactId}")
                call.respond(HttpStatusCode.Created, createdParticipant)
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid conversation ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid conversation ID")
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to add participant: ${e.message}")
                call.respondInternalError("Failed to add participant: ${e.message}")
            }
        }

        // Read all participants by conversation
        get("/conversations/{conversationId}/participants") {
            try {
                val userId = call.getUserId()
                val conversationId = call.parameters["conversationId"] 
                    ?: throw IllegalArgumentException("Conversation ID is required")
                
                call.logWithUser("info", "Reading participants for conversation: $conversationId")

                val result = participantService.readAllByConversation(conversationId)
                call.logWithUser("info", "Retrieved ${result.participants.size} participants")
                call.respond(HttpStatusCode.OK, result)
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid conversation ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid conversation ID")
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to read participants: ${e.message}")
                call.respondInternalError("Failed to read participants: ${e.message}")
            }
        }

        // Read participant by conversation ID and contact ID
        get("/conversations/{conversationId}/participants/{contactId}") {
            try {
                val userId = call.getUserId()
                val conversationId = call.parameters["conversationId"] 
                    ?: throw IllegalArgumentException("Conversation ID is required")
                val contactId = call.parameters["contactId"] 
                    ?: throw IllegalArgumentException("Contact ID is required")
                
                call.logWithUser("info", "Reading participant: conversation=$conversationId, contact=$contactId")
                
                val participant = participantService.readByConversationAndContact(conversationId, contactId)
                call.logWithUser("info", "Participant retrieved successfully: ${participant.contactId}")
                call.respond(HttpStatusCode.OK, participant)
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid ID format")
            } catch (e: Exception) {
                if (e.message == "Participant not found") {
                    call.logWithUser("warn", "Participant not found: conversation=${call.parameters["conversationId"]}, contact=${call.parameters["contactId"]}")
                    call.respondNotFound("Participant not found")
                } else {
                    call.logWithUser("error", "Failed to read participant: ${e.message}")
                    call.respondInternalError("Failed to read participant: ${e.message}")
                }
            }
        }

        // Update participant
        put("/conversations/{conversationId}/participants/{contactId}") {
            try {
                val userId = call.getUserId()
                val conversationId = call.parameters["conversationId"] 
                    ?: throw IllegalArgumentException("Conversation ID is required")
                val contactId = call.parameters["contactId"] 
                    ?: throw IllegalArgumentException("Contact ID is required")
                
                call.logWithUser("info", "Updating participant: conversation=$conversationId, contact=$contactId")
                
                val participant = call.receive<ParticipantUpdateRequest>()
                
                // Валидация
                val validationErrors = validateParticipantUpdate(participant)
                if (validationErrors.isNotEmpty()) {
                    call.logWithUser("warn", "Participant validation failed for update: ${validationErrors.joinToString { "${it.field}: ${it.message}" }}")
                    call.respondValidationError("Validation failed", validationErrors)
                    return@put
                }
                
                val updatedParticipant = participantService.update(conversationId, contactId, participant)
                call.logWithUser("info", "Participant updated successfully: ${updatedParticipant.contactId}")
                call.respond(HttpStatusCode.OK, updatedParticipant)
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid ID format for update: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid ID format")
            } catch (e: Exception) {
                if (e.message == "Participant not found") {
                    call.logWithUser("warn", "Participant not found for update: conversation=${call.parameters["conversationId"]}, contact=${call.parameters["contactId"]}")
                    call.respondNotFound("Participant not found")
                } else {
                    call.logWithUser("error", "Failed to update participant: ${e.message}")
                    call.respondInternalError("Failed to update participant: ${e.message}")
                }
            }
        }

        // Delete participant
        delete("/conversations/{conversationId}/participants/{contactId}") {
            try {
                val userId = call.getUserId()
                val conversationId = call.parameters["conversationId"] 
                    ?: throw IllegalArgumentException("Conversation ID is required")
                val contactId = call.parameters["contactId"] 
                    ?: throw IllegalArgumentException("Contact ID is required")
                
                call.logWithUser("info", "Removing participant: conversation=$conversationId, contact=$contactId")
                
                participantService.delete(conversationId, contactId)
                call.logWithUser("info", "Participant removed successfully: conversation=$conversationId, contact=$contactId")
                call.respond(HttpStatusCode.OK, mapOf<String, Any>("message" to "Participant removed successfully", "removedBy" to (userId ?: "unknown")))
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid ID format for delete: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid ID format")
            } catch (e: Exception) {
                if (e.message == "Participant not found") {
                    call.logWithUser("warn", "Participant not found for delete: conversation=${call.parameters["conversationId"]}, contact=${call.parameters["contactId"]}")
                    call.respondNotFound("Participant not found")
                } else {
                    call.logWithUser("error", "Failed to remove participant: ${e.message}")
                    call.respondInternalError("Failed to remove participant: ${e.message}")
                }
            }
        }
    }
}
