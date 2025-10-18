package com.task_micro.controller

import com.task_micro.model.Task
import com.task_micro.service.TaskService
import com.task_micro.plugin.validateTask
import com.task_micro.plugin.respondValidationError
import com.task_micro.plugin.respondInternalError
import com.task_micro.plugin.getUserId
import com.task_micro.plugin.logWithUser
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.litote.kmongo.coroutine.CoroutineDatabase

fun Application.configureTaskCreateRouting(database: CoroutineDatabase) {
    val taskService = TaskService(database)

    routing {
        // Create new task
        post {
            try {
                val userId = call.getUserId()
                val task = call.receive<Task>()
                
                // Ensure creatorId matches authenticated user FIRST
                val taskWithCreator = task.copy(creatorId = userId ?: throw IllegalArgumentException("User ID is required"))
                
                // Validate task AFTER setting creatorId
                val validationErrors = validateTask(taskWithCreator)
                if (validationErrors.isNotEmpty()) {
                    call.respondValidationError("Validation failed", validationErrors)
                    return@post
                }
                
                val id = taskService.create(taskWithCreator)
                call.logWithUser("info", "Task created successfully with ID: $id")
                call.respond(HttpStatusCode.Created, mapOf("id" to id, "createdBy" to userId))
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to create task: ${e.message}")
                call.respondInternalError("Failed to create task")
            }
        }
    }
}
