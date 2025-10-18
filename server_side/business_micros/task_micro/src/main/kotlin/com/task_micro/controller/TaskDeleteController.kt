package com.task_micro.controller

import com.task_micro.service.TaskService
import com.task_micro.plugin.respondInternalError
import com.task_micro.plugin.respondNotFound
import com.task_micro.plugin.getUserId
import com.task_micro.plugin.logWithUser
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.litote.kmongo.coroutine.CoroutineDatabase

fun Application.configureTaskDeleteRouting(database: CoroutineDatabase) {
    val taskService = TaskService(database)

    routing {
        // Delete task
        delete("/{id}") {
            try {
                val id = call.parameters["id"]
                    ?: throw IllegalArgumentException("Task ID is required")
                
                val userId = call.getUserId()
                taskService.deleteByCreator(id, userId ?: throw IllegalArgumentException("User ID is required"))
                call.logWithUser("info", "Task deleted successfully: $id by user $userId")
                call.respond(HttpStatusCode.OK, mapOf("message" to "Task deleted successfully"))
            } catch (e: Exception) {
                if (e.message == "Task not found or access denied") {
                    call.respondNotFound("Task not found or access denied")
                } else {
                    call.logWithUser("error", "Failed to delete task: ${e.message}")
                    call.respondInternalError("Failed to delete task")
                }
            }
        }
    }
}
