package com.contact_micro.controller

import com.contact_micro.model.ContactCreateRequest
import com.contact_micro.model.ContactUpdateRequest
import com.contact_micro.model.ContactSearchResponse
import com.contact_micro.service.ContactService
import com.contact_micro.config.PaginationConfig
import com.contact_micro.config.AvatarConfig
import com.contact_micro.plugin.validateContactCreate
import com.contact_micro.plugin.validateContactUpdate
import com.contact_micro.plugin.respondValidationError
import com.contact_micro.plugin.respondInternalError
import com.contact_micro.plugin.respondBadRequest
import com.contact_micro.plugin.respondNotFound
import com.contact_micro.plugin.getUserId
import com.contact_micro.plugin.logWithUser
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import java.sql.Connection

fun Application.configureContactRouting(dbConnection: Connection, paginationConfig: PaginationConfig, avatarConfig: AvatarConfig) {
    val contactService = ContactService(dbConnection, paginationConfig, avatarConfig)
    
    routing {
        // Create contact
        post("/") {
            try {
                val userId = call.getUserId()
                call.logWithUser("info", "Creating new contact")
                
                val contact = call.receive<ContactCreateRequest>()
                
                // Валидация
                val validationErrors = validateContactCreate(contact)
                if (validationErrors.isNotEmpty()) {
                    call.logWithUser("warn", "Contact validation failed: ${validationErrors.joinToString { "${it.field}: ${it.message}" }}")
                    call.respondValidationError("Validation failed", validationErrors)
                    return@post
                }
                
                val id = contactService.create(contact, userId ?: throw IllegalArgumentException("Okta-User-ID header is required"))
                call.logWithUser("info", "Contact created successfully with ID: $id")
                call.respond(HttpStatusCode.Created, mapOf<String, Any>("id" to id, "createdBy" to userId))
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to create contact: ${e.message}")
                call.respondInternalError("Failed to create contact: ${e.message}")
            }
        }

        // Read all contacts with search and pagination, or by specific IDs
        get("/") {
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
                    
                    call.logWithUser("info", "Reading ${ids.size} contacts by IDs")
                    
                    val contacts = contactService.readByIds(ids)
                    call.logWithUser("info", "Retrieved ${contacts.size} contacts out of ${ids.size} requested")
                    
                    // Возвращаем результат в том же формате, что и обычный поиск
                    val result = ContactSearchResponse(
                        contacts = contacts,
                        hasMore = false, // Поиск по ID не поддерживает пагинацию
                        nextCursor = null,
                        totalCount = contacts.size
                    )
                    call.respond(HttpStatusCode.OK, result)
                } else {
                    // Обычный поиск с пагинацией, фильтрацией и сортировкой
                    
                    // Получаем параметры фильтрации
                    val filters = mutableMapOf<String, String>()
                    val filterFields = listOf("role", "department", "company", "is_online", "locale", "timezone", 
                                            "username", "email", "phone", "firstName", "lastName", "displayName", 
                                            "statusMessage", "rank", "position")
                    
                    filterFields.forEach { field ->
                        call.request.queryParameters[field]?.let { value ->
                            if (value.isNotBlank()) {
                                filters[field] = value
                            }
                        }
                    }
                    
                    // Получаем параметры сортировки
                    val sortBy = call.request.queryParameters["sortBy"]
                    val sortOrder = call.request.queryParameters["sortOrder"]
                    
                    call.logWithUser("info", "Searching contacts: query='$searchQuery', cursor='$cursor', limit=$limit, filters=$filters, sortBy=$sortBy, sortOrder=$sortOrder")

                    val result = contactService.readAll(searchQuery, cursor, limit, filters, sortBy, sortOrder)
                    call.logWithUser("info", "Retrieved ${result.contacts.size} contacts, hasMore=${result.hasMore}")
                    call.respond(HttpStatusCode.OK, result)
                }
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid request parameters: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid request parameters")
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to read contacts: ${e.message}")
                call.respondInternalError("Failed to read contacts: ${e.message}")
            }
        }

        // Get current user's contact data
        get("/me") {
            try {
                val userId = call.getUserId()
                call.logWithUser("info", "Reading current user's contact data")
                
                val contact = contactService.readById(userId ?: throw IllegalArgumentException("Okta-User-ID header is required"))
                call.logWithUser("info", "Current user contact retrieved successfully: ${contact.displayName ?: contact.email ?: "Unknown"}")
                call.respond(HttpStatusCode.OK, contact)
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid user ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid user ID")
            } catch (e: Exception) {
                if (e.message == "Contact not found") {
                    call.logWithUser("warn", "Current user contact not found")
                    call.respondNotFound("Contact not found")
                } else {
                    call.logWithUser("error", "Failed to read current user contact: ${e.message}")
                    call.respondInternalError("Failed to read contact: ${e.message}")
                }
            }
        }

        // Update current user's contact data
        put("/me") {
            try {
                val userId = call.getUserId()
                call.logWithUser("info", "Updating current user's contact data")
                
                val contact = call.receive<ContactUpdateRequest>()
                
                // Валидация
                val validationErrors = validateContactUpdate(contact)
                if (validationErrors.isNotEmpty()) {
                    call.logWithUser("warn", "Contact validation failed for current user update: ${validationErrors.joinToString { "${it.field}: ${it.message}" }}")
                    call.respondValidationError("Validation failed", validationErrors)
                    return@put
                }
                
                contactService.update(userId ?: throw IllegalArgumentException("Okta-User-ID header is required"), contact)
                call.logWithUser("info", "Current user contact updated successfully")
                call.respond(HttpStatusCode.OK, mapOf<String, Any>("message" to "Contact updated successfully", "updatedBy" to (userId ?: "unknown")))
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid user ID format for current user update: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid user ID")
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to update current user contact: ${e.message}")
                call.respondInternalError("Failed to update contact: ${e.message}")
            }
        }

        // Read contact by ID
        get("/{id}") {
            try {
                val userId = call.getUserId()
                val id = call.parameters["id"] 
                    ?: throw IllegalArgumentException("Contact ID is required")
                
                call.logWithUser("info", "Reading contact with ID: $id")
                
                val contact = contactService.readById(id)
                call.logWithUser("info", "Contact retrieved successfully: ${contact.displayName ?: contact.email ?: "Unknown"}")
                call.respond(HttpStatusCode.OK, contact)
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid contact ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid contact ID")
            } catch (e: Exception) {
                if (e.message == "Contact not found") {
                    call.logWithUser("warn", "Contact not found with ID: ${call.parameters["id"]}")
                    call.respondNotFound("Contact not found")
                } else {
                    call.logWithUser("error", "Failed to read contact with ID: ${call.parameters["id"]}, error: ${e.message}")
                    call.respondInternalError("Failed to read contact: ${e.message}")
                }
            }
        }

        // Update contact
        put("/{id}") {
            try {
                val userId = call.getUserId()
                val id = call.parameters["id"] 
                    ?: throw IllegalArgumentException("Contact ID is required")
                
                call.logWithUser("info", "Updating contact with ID: $id")
                
                val contact = call.receive<ContactUpdateRequest>()
                
                // Валидация
                val validationErrors = validateContactUpdate(contact)
                if (validationErrors.isNotEmpty()) {
                    call.logWithUser("warn", "Contact validation failed for update: ${validationErrors.joinToString { "${it.field}: ${it.message}" }}")
                    call.respondValidationError("Validation failed", validationErrors)
                    return@put
                }
                
                contactService.update(id, contact)
                call.logWithUser("info", "Contact updated successfully with ID: $id")
                call.respond(HttpStatusCode.OK, mapOf<String, Any>("message" to "Contact updated successfully", "updatedBy" to (userId ?: "unknown")))
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid contact ID format for update: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid contact ID")
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to update contact with ID: ${call.parameters["id"]}, error: ${e.message}")
                call.respondInternalError("Failed to update contact: ${e.message}")
            }
        }

        // Delete contact
        delete("/{id}") {
            try {
                val userId = call.getUserId()
                val id = call.parameters["id"] 
                    ?: throw IllegalArgumentException("Contact ID is required")
                
                call.logWithUser("info", "Deleting contact with ID: $id")
                
                contactService.delete(id)
                call.logWithUser("info", "Contact deleted successfully with ID: $id")
                call.respond(HttpStatusCode.OK, mapOf<String, Any>("message" to "Contact deleted successfully", "deletedBy" to (userId ?: "unknown")))
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid contact ID format for delete: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid contact ID")
            } catch (e: Exception) {
                call.logWithUser("warn", "Contact not found for delete with ID: ${call.parameters["id"]}")
                call.respondNotFound("Contact not found")
            }
        }
    }
}
