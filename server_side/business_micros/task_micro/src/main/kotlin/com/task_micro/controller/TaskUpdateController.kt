package com.task_micro.controller

import com.task_micro.model.Task
import com.task_micro.service.TaskService
import com.task_micro.plugin.validateTask
import com.task_micro.plugin.respondValidationError
import com.task_micro.plugin.respondInternalError
import com.task_micro.plugin.respondBadRequest
import com.task_micro.plugin.respondNotFound
import com.task_micro.plugin.getUserId
import com.task_micro.plugin.logWithUser
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.litote.kmongo.coroutine.CoroutineDatabase

fun Application.configureTaskUpdateRouting(database: CoroutineDatabase) {
    val taskService = TaskService(database)

    routing {
        // Update task
        put("/{id}") {
            try {
                val id = call.parameters["id"]
                    ?: throw IllegalArgumentException("Task ID is required")
                
                val userId = call.getUserId()
                val task = call.receive<Task>()
                
                // Validate task
                val validationErrors = validateTask(task)
                if (validationErrors.isNotEmpty()) {
                    call.respondValidationError("Validation failed", validationErrors)
                    return@put
                }

                // Update task with creator validation
                taskService.updateByCreator(id, task, userId ?: throw IllegalArgumentException("User ID is required"))
                call.logWithUser("info", "Task updated successfully: $id")
                call.respond(HttpStatusCode.OK, mapOf("message" to "Task updated successfully"))
            } catch (e: Exception) {
                if (e.message == "Task not found or access denied") {
                    call.respondNotFound("Task not found or access denied")
                } else {
                    call.logWithUser("error", "Failed to update task: ${e.message}")
                    call.respondInternalError("Failed to update task")
                }
            }
        }

        // Update task status
        patch("/{id}/status") {
            try {
                val id = call.parameters["id"]
                    ?: throw IllegalArgumentException("Task ID is required")
                
                val userId = call.getUserId()
                val statusData = call.receive<Map<String, String>>()
                val status = statusData["status"]
                    ?: throw IllegalArgumentException("Status is required")
                
                if (status !in listOf("open", "in_progress", "completed", "cancelled")) {
                    call.respondBadRequest("Invalid status. Must be one of: open, in_progress, completed, cancelled")
                    return@patch
                }
                
                taskService.updateStatusByCreator(id, status, userId ?: throw IllegalArgumentException("User ID is required"))
                call.logWithUser("info", "Task status updated to $status for task: $id")
                call.respond(HttpStatusCode.OK, mapOf("message" to "Task status updated successfully"))
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid request")
            } catch (e: Exception) {
                if (e.message == "Task not found or access denied") {
                    call.respondNotFound("Task not found or access denied")
                } else {
                    call.logWithUser("error", "Failed to update task status: ${e.message}")
                    call.respondInternalError("Failed to update task status")
                }
            }
        }

        // Update task priority
        patch("/{id}/priority") {
            try {
                val id = call.parameters["id"]
                    ?: throw IllegalArgumentException("Task ID is required")
                
                val userId = call.getUserId()
                val priorityData = call.receive<Map<String, Int>>()
                val priority = priorityData["priority"]
                    ?: throw IllegalArgumentException("Priority is required")
                
                if (priority !in 1..5) {
                    call.respondBadRequest("Priority must be between 1 and 5")
                    return@patch
                }
                
                taskService.updatePriorityByCreator(id, priority, userId ?: throw IllegalArgumentException("User ID is required"))
                call.logWithUser("info", "Task priority updated to $priority for task: $id")
                call.respond(HttpStatusCode.OK, mapOf("message" to "Task priority updated successfully"))
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid request")
            } catch (e: Exception) {
                if (e.message == "Task not found or access denied") {
                    call.respondNotFound("Task not found or access denied")
                } else {
                    call.logWithUser("error", "Failed to update task priority: ${e.message}")
                    call.respondInternalError("Failed to update task priority")
                }
            }
        }
    }
}
