package com.example.controller

import com.example.model.City
import com.example.model.CityService
import com.example.plugin.validateCity
import com.example.plugin.respondValidationError
import com.example.plugin.respondInternalError
import com.example.plugin.respondBadRequest
import com.example.plugin.respondNotFound
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import java.sql.Connection

fun Application.configureCitiesRouting(dbConnection: Connection) {
    val cityService = CityService(dbConnection)
    
    routing {
        // Create city
        post("/cities") {
            try {
                val city = call.receive<City>()
                
                // Валидация
                val validationErrors = validateCity(city)
                if (validationErrors.isNotEmpty()) {
                    call.respondValidationError("Validation failed", validationErrors)
                    return@post
                }
                
                val id = cityService.create(city)
                call.respond(HttpStatusCode.Created, mapOf("id" to id))
            } catch (e: Exception) {
                call.respondInternalError("Failed to create city: ${e.message}")
            }
        }

        // Read city
        get("/cities/{id}") {
            try {
                val id = call.parameters["id"]?.toIntOrNull() 
                    ?: throw IllegalArgumentException("Invalid city ID format")
                
                val city = cityService.read(id)
                call.respond(HttpStatusCode.OK, city)
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid city ID")
            } catch (e: Exception) {
                call.respondNotFound("City not found")
            }
        }

        // Update city
        put("/cities/{id}") {
            try {
                val id = call.parameters["id"]?.toIntOrNull() 
                    ?: throw IllegalArgumentException("Invalid city ID format")
                
                val city = call.receive<City>()
                
                // Валидация
                val validationErrors = validateCity(city)
                if (validationErrors.isNotEmpty()) {
                    call.respondValidationError("Validation failed", validationErrors)
                    return@put
                }
                
                cityService.update(id, city)
                call.respond(HttpStatusCode.OK, mapOf("message" to "City updated successfully"))
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid city ID")
            } catch (e: Exception) {
                call.respondNotFound("City not found")
            }
        }

        // Delete city
        delete("/cities/{id}") {
            try {
                val id = call.parameters["id"]?.toIntOrNull() 
                    ?: throw IllegalArgumentException("Invalid city ID format")
                
                cityService.delete(id)
                call.respond(HttpStatusCode.OK, mapOf("message" to "City deleted successfully"))
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid city ID")
            } catch (e: Exception) {
                call.respondNotFound("City not found")
            }
        }
    }
}
