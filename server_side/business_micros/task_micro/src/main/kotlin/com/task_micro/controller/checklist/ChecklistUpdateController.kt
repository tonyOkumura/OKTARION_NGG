package com.task_micro.controller.checklist

import com.task_micro.service.ChecklistService
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

fun Application.configureChecklistUpdateRouting(database: CoroutineDatabase) {
    val checklistService = ChecklistService(database)

    routing {
        // Update checklist item
        put("/tasks/{taskId}/checklist/{itemId}") {
            try {
                val taskId = call.parameters["taskId"]
                    ?: throw IllegalArgumentException("Task ID is required")
                
                val itemId = call.parameters["itemId"]
                    ?: throw IllegalArgumentException("Item ID is required")
                
                val userId = call.getUserId()
                val requestData = call.receive<Map<String, String>>()
                
                val title = requestData["title"]
                val isCompleted = requestData["isCompleted"]?.toBooleanStrictOrNull()
                val completedBy = requestData["completedBy"]
                
                if (title != null && title.isBlank()) {
                    call.respondBadRequest("Title cannot be blank")
                    return@put
                }
                
                checklistService.updateChecklistItem(taskId, itemId, title, isCompleted, completedBy)
                call.logWithUser("info", "Checklist item updated: $itemId for task: $taskId")
                call.respond(HttpStatusCode.OK, mapOf("message" to "Checklist item updated successfully"))
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid request")
            } catch (e: Exception) {
                if (e.message == "Checklist item not found") {
                    call.respondNotFound("Checklist item not found")
                } else {
                    call.logWithUser("error", "Failed to update checklist item: ${e.message}")
                    call.respondInternalError("Failed to update checklist item")
                }
            }
        }

        // Toggle checklist item completion
        patch("/tasks/{taskId}/checklist/{itemId}/toggle") {
            try {
                val taskId = call.parameters["taskId"]
                    ?: throw IllegalArgumentException("Task ID is required")
                
                val itemId = call.parameters["itemId"]
                    ?: throw IllegalArgumentException("Item ID is required")
                
                val userId = call.getUserId()
                
                // Get current item to toggle completion
                val currentItem = checklistService.getChecklistItem(taskId, itemId)
                val newCompletedStatus = !currentItem.isCompleted
                
                checklistService.updateChecklistItem(
                    taskId, 
                    itemId, 
                    null, 
                    newCompletedStatus, 
                    if (newCompletedStatus) userId else null
                )
                
                call.logWithUser("info", "Checklist item toggled: $itemId for task: $taskId (completed: $newCompletedStatus)")
                call.respond(HttpStatusCode.OK, mapOf("message" to "Checklist item toggled successfully", "isCompleted" to newCompletedStatus.toString()))
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid request")
            } catch (e: Exception) {
                if (e.message == "Checklist item not found") {
                    call.respondNotFound("Checklist item not found")
                } else {
                    call.logWithUser("error", "Failed to toggle checklist item: ${e.message}")
                    call.respondInternalError("Failed to toggle checklist item")
                }
            }
        }
    }
}
