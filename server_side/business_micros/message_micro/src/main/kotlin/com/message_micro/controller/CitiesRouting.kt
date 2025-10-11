package com.message_micro.controller

import com.message_micro.model.City
import com.message_micro.model.CityService
import com.message_micro.plugin.validateCity
import com.message_micro.plugin.respondValidationError
import com.message_micro.plugin.respondInternalError
import com.message_micro.plugin.respondBadRequest
import com.message_micro.plugin.respondNotFound
import com.message_micro.plugin.getUserId
import com.message_micro.plugin.logWithUser
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import java.sql.Connection

fun Application.configureCitiesRouting(dbConnection: Connection) {
    val cityService = CityService(dbConnection)
    
    routing {
        // Обработка CORS preflight запросов для cities
        options("/cities") {
            call.respond(HttpStatusCode.OK)
        }
        
        options("/cities/{id}") {
            call.respond(HttpStatusCode.OK)
        }
        
        // Create city
        post("/cities") {
            try {
                val userId = call.getUserId()
                call.logWithUser("info", "Creating new city")
                
                val city = call.receive<City>()
                
                // Валидация
                val validationErrors = validateCity(city)
                if (validationErrors.isNotEmpty()) {
                    call.logWithUser("warn", "City validation failed: ${validationErrors.joinToString { "${it.field}: ${it.message}" }}")
                    call.respondValidationError("Validation failed", validationErrors)
                    return@post
                }
                
                val id = cityService.create(city)
                call.logWithUser("info", "City created successfully with ID: $id")
                call.respond(HttpStatusCode.Created, mapOf("id" to id.toString(), "createdBy" to userId))
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to create city: ${e.message}")
                call.respondInternalError("Failed to create city: ${e.message}")
            }
        }

        // Read city
        get("/cities/{id}") {
            try {
                val userId = call.getUserId()
                val id = call.parameters["id"]?.toIntOrNull() 
                    ?: throw IllegalArgumentException("Invalid city ID format")
                
                call.logWithUser("info", "Reading city with ID: $id")
                
                val city = cityService.read(id)
                call.logWithUser("info", "City retrieved successfully: ${city.name}")
                call.respond(HttpStatusCode.OK, city)
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid city ID format: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid city ID")
            } catch (e: Exception) {
                call.logWithUser("warn", "City not found with ID: ${call.parameters["id"]}")
                call.respondNotFound("City not found")
            }
        }

        // Update city
        put("/cities/{id}") {
            try {
                val userId = call.getUserId()
                val id = call.parameters["id"]?.toIntOrNull() 
                    ?: throw IllegalArgumentException("Invalid city ID format")
                
                call.logWithUser("info", "Updating city with ID: $id")
                
                val city = call.receive<City>()
                
                // Валидация
                val validationErrors = validateCity(city)
                if (validationErrors.isNotEmpty()) {
                    call.logWithUser("warn", "City validation failed for update: ${validationErrors.joinToString { "${it.field}: ${it.message}" }}")
                    call.respondValidationError("Validation failed", validationErrors)
                    return@put
                }
                
                cityService.update(id, city)
                call.logWithUser("info", "City updated successfully: ${city.name}")
                call.respond(HttpStatusCode.OK, mapOf("message" to "City updated successfully", "updatedBy" to userId))
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid city ID format for update: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid city ID")
            } catch (e: Exception) {
                call.logWithUser("warn", "City not found for update with ID: ${call.parameters["id"]}")
                call.respondNotFound("City not found")
            }
        }

        // Delete city
        delete("/cities/{id}") {
            try {
                val userId = call.getUserId()
                val id = call.parameters["id"]?.toIntOrNull() 
                    ?: throw IllegalArgumentException("Invalid city ID format")
                
                call.logWithUser("info", "Deleting city with ID: $id")
                
                cityService.delete(id)
                call.logWithUser("info", "City deleted successfully with ID: $id")
                call.respond(HttpStatusCode.OK, mapOf("message" to "City deleted successfully", "deletedBy" to userId))
            } catch (e: IllegalArgumentException) {
                call.logWithUser("warn", "Invalid city ID format for delete: ${e.message}")
                call.respondBadRequest(e.message ?: "Invalid city ID")
            } catch (e: Exception) {
                call.logWithUser("warn", "City not found for delete with ID: ${call.parameters["id"]}")
                call.respondNotFound("City not found")
            }
        }
    }
}
