package com.conversation_micro.controller

import com.conversation_micro.model.ConversationCreateRequest
import com.conversation_micro.model.ConversationUpdateRequest
import com.conversation_micro.model.AddParticipantsRequest
import com.conversation_micro.model.RemoveParticipantsRequest
import com.conversation_micro.model.AddParticipantsResponse
import com.conversation_micro.model.RemoveParticipantsResponse
import com.conversation_micro.model.ConversationListResponse
import com.conversation_micro.model.ConversationService
import com.conversation_micro.config.PaginationConfig
import com.conversation_micro.plugin.validateConversationCreate
import com.conversation_micro.plugin.validateConversationUpdate
import com.conversation_micro.plugin.validateAddParticipants
import com.conversation_micro.plugin.validateRemoveParticipants
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

fun Application.configureConversationRouting(dbConnection: Connection, paginationConfig: PaginationConfig) {
    val conversationService = ConversationService(dbConnection, paginationConfig)
    
    routing {

        // Create conversation
        post("/conversations") {
            try {
                val userId = call.getUserId()
                call.logWithUser("info", "Creating new conversation")
                
                val conversation = call.receive<ConversationCreateRequest>()
                
                // Валидация
                val validationErrors = validateConversationCreate(conversation)
                if (validationErrors.isNotEmpty()) {
                    call.logWithUser("warn", "Conversation validation failed: ${validationErrors.joinToString { "${it.field}: ${it.message}" }}")
                    call.respondValidationError("Validation failed", validationErrors)
                    return@post
                }
                
                val id = conversationService.create(conversation, userId ?: throw IllegalArgumentException("Okta-User-ID header is required"))
                call.logWithUser("info", "Conversation created successfully with ID: $id")
                call.respond(HttpStatusCode.Created, mapOf<String, Any>("id" to id, "createdBy" to userId))
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to create conversation: ${e.message}")
                call.respondInternalError("Failed to create conversation: ${e.message}")
            }
        }

        // Read all conversations with pagination and search
        get("/conversations") {
            try {
                val userId = call.getUserId()
                
                // Получаем параметры запроса
                val searchQuery = call.request.queryParameters["search"]
                val cursor = call.request.queryParameters["cursor"]
                val limitParam = call.request.queryParameters["limit"]?.toIntOrNull()
                val limit = if (limitParam != null && limitParam in 1..paginationConfig.maxLimit) limitParam else null
                
                // Получаем параметр ids для поиска по конкретным ID
                val idsParam = call.request.queryParameters["ids"]
                val ids = if (idsParam != null) {
                    idsParam.split(",").map { it.trim() }.filter { it.isNotEmpty() }
                } else null

                // Если указаны конкретные ID, используем поиск по ID
                if (ids != null) {
                    if (ids.isEmpty()) {
                        call.logWithUser("warn", "Empty IDs list provided")
                        call.respondBadRequest("IDs list cannot be empty")
                        return@get
                    }
                    
                    if (ids.size > 100) {
                        call.logWithUser("warn", "Too many IDs provided: ${ids.size}")
                        call.respondBadRequest("Maximum 100 IDs allowed per request")
                        return@get
                    }
                    
                    call.logWithUser("info", "Reading ${ids.size} conversations by IDs")
                    
                    val conversations = conversationService.readByIds(userId ?: throw IllegalArgumentException("Okta-User-ID header is required"), ids)
                    call.logWithUser("info", "Retrieved ${conversations.size} conversations out of ${ids.size} requested")
                    
                    // Возвращаем результат в том же формате, что и обычный поиск
                    val result = ConversationListResponse(
                        conversations = conversations,
                        hasMore = false, // Поиск по ID не поддерживает пагинацию
                        nextCursor = null
                    )
                    call.respond(HttpStatusCode.OK, result)
                } else {
                    // Обычный поиск с пагинацией
                    call.logWithUser("info", "Reading conversations: search='$searchQuery', cursor='$cursor', limit=$limit")

                    val result = conversationService.readAll(userId ?: throw IllegalArgumentException("Okta-User-ID header is required"), searchQuery, cursor, limit)
                    call.logWithUser("info", "Retrieved ${result.conversations.size} conversations, hasMore=${result.hasMore}")
                    call.respond(HttpStatusCode.OK, result)
                }
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid request parameters: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid request parameters")
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to read conversations: ${e.message}")
                call.respondInternalError("Failed to read conversations: ${e.message}")
            }
        }

        // Read conversation by ID
        get("/conversations/{id}") {
            try {
                val userId = call.getUserId()
                val id = call.parameters["id"] 
                    ?: throw IllegalArgumentException("Conversation ID is required")
                
                call.logWithUser("info", "Reading conversation with ID: $id")
                
                val conversation = conversationService.readById(id)
                call.logWithUser("info", "Conversation retrieved successfully: ${conversation.name ?: "Unnamed"}")
                call.respond(HttpStatusCode.OK, conversation)
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid conversation ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid conversation ID")
            } catch (e: Exception) {
                if (e.message == "Conversation not found") {
                    call.logWithUser("warn", "Conversation not found with ID: ${call.parameters["id"]}")
                    call.respondNotFound("Conversation not found")
                } else {
                    call.logWithUser("error", "Failed to read conversation with ID: ${call.parameters["id"]}, error: ${e.message}")
                    call.respondInternalError("Failed to read conversation: ${e.message}")
                }
            }
        }

        // Update conversation
        put("/conversations/{id}") {
            try {
                val userId = call.getUserId()
                val id = call.parameters["id"] 
                    ?: throw IllegalArgumentException("Conversation ID is required")
                
                call.logWithUser("info", "Updating conversation with ID: $id")
                
                val conversation = call.receive<ConversationUpdateRequest>()
                
                // Валидация
                val validationErrors = validateConversationUpdate(conversation)
                if (validationErrors.isNotEmpty()) {
                    call.logWithUser("warn", "Conversation validation failed for update: ${validationErrors.joinToString { "${it.field}: ${it.message}" }}")
                    call.respondValidationError("Validation failed", validationErrors)
                    return@put
                }
                
                conversationService.update(id, conversation)
                call.logWithUser("info", "Conversation updated successfully with ID: $id")
                call.respond(HttpStatusCode.OK, mapOf<String, Any>("message" to "Conversation updated successfully", "updatedBy" to (userId ?: "unknown")))
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid conversation ID format for update: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid conversation ID")
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to update conversation with ID: ${call.parameters["id"]}, error: ${e.message}")
                call.respondInternalError("Failed to update conversation: ${e.message}")
            }
        }

        // Delete conversation
        delete("/conversations/{id}") {
            try {
                val userId = call.getUserId()
                val id = call.parameters["id"] 
                    ?: throw IllegalArgumentException("Conversation ID is required")
                
                call.logWithUser("info", "Deleting conversation with ID: $id")
                
                conversationService.delete(id)
                call.logWithUser("info", "Conversation deleted successfully with ID: $id")
                call.respond(HttpStatusCode.OK, mapOf<String, Any>("message" to "Conversation deleted successfully", "deletedBy" to (userId ?: "unknown")))
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid conversation ID format for delete: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid conversation ID")
            } catch (e: Exception) {
                call.logWithUser("warn", "Conversation not found for delete with ID: ${call.parameters["id"]}")
                call.respondNotFound("Conversation not found")
            }
        }

        // Add participants to group chat
        post("/conversations/{id}/add") {
            try {
                val userId = call.getUserId()
                val conversationId = call.parameters["id"] 
                    ?: throw IllegalArgumentException("Conversation ID is required")
                
                call.logWithUser("info", "Adding participants to conversation: $conversationId")
                
                val request = call.receive<AddParticipantsRequest>()
                
                // Валидация
                val validationErrors = validateAddParticipants(request)
                if (validationErrors.isNotEmpty()) {
                    call.logWithUser("warn", "Add participants validation failed: ${validationErrors.joinToString { "${it.field}: ${it.message}" }}")
                    call.respondValidationError("Validation failed", validationErrors)
                    return@post
                }
                
                val addedParticipants = conversationService.addParticipants(conversationId, request.contactIds, userId ?: throw IllegalArgumentException("Okta-User-ID header is required"))
                call.logWithUser("info", "Added ${addedParticipants.size} participants to conversation: $conversationId")
                call.respond(HttpStatusCode.OK, AddParticipantsResponse(
                    message = "Participants added successfully",
                    addedCount = addedParticipants.size,
                    participants = addedParticipants
                ))
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid conversation ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid conversation ID")
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to add participants: ${e.message}")
                call.respondInternalError("Failed to add participants: ${e.message}")
            }
        }

        // Remove participants from group chat
        post("/conversations/{id}/remove") {
            try {
                val userId = call.getUserId()
                val conversationId = call.parameters["id"] 
                    ?: throw IllegalArgumentException("Conversation ID is required")
                
                call.logWithUser("info", "Removing participants from conversation: $conversationId")
                
                val request = call.receive<RemoveParticipantsRequest>()
                
                // Валидация
                val validationErrors = validateRemoveParticipants(request)
                if (validationErrors.isNotEmpty()) {
                    call.logWithUser("warn", "Remove participants validation failed: ${validationErrors.joinToString { "${it.field}: ${it.message}" }}")
                    call.respondValidationError("Validation failed", validationErrors)
                    return@post
                }
                
                val removedCount = conversationService.removeParticipants(conversationId, request.contactIds, userId ?: throw IllegalArgumentException("Okta-User-ID header is required"))
                call.logWithUser("info", "Removed $removedCount participants from conversation: $conversationId")
                call.respond(HttpStatusCode.OK, RemoveParticipantsResponse(
                    message = "Participants removed successfully",
                    removedCount = removedCount
                ))
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid conversation ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid conversation ID")
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to remove participants: ${e.message}")
                call.respondInternalError("Failed to remove participants: ${e.message}")
            }
        }
    }
}
