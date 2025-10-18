package com.task_micro.controller.checklist

import com.task_micro.service.ChecklistService
import com.task_micro.plugin.respondInternalError
import com.task_micro.plugin.respondNotFound
import com.task_micro.plugin.getUserId
import com.task_micro.plugin.logWithUser
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.litote.kmongo.coroutine.CoroutineDatabase

fun Application.configureChecklistReadRouting(database: CoroutineDatabase) {
    val checklistService = ChecklistService(database)

    routing {
        // Get checklist items for a task
        get("/tasks/{taskId}/checklist") {
            try {
                val taskId = call.parameters["taskId"]
                    ?: throw IllegalArgumentException("Task ID is required")
                
                val userId = call.getUserId()
                val items = checklistService.getChecklistItemsForTask(taskId)
                call.logWithUser("info", "Retrieved ${items.size} checklist items for task $taskId")
                call.respond(HttpStatusCode.OK, items)
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to retrieve checklist items: ${e.message}")
                call.respondInternalError("Failed to retrieve checklist items")
            }
        }

        // Get specific checklist item
        get("/tasks/{taskId}/checklist/{itemId}") {
            try {
                val taskId = call.parameters["taskId"]
                    ?: throw IllegalArgumentException("Task ID is required")
                
                val itemId = call.parameters["itemId"]
                    ?: throw IllegalArgumentException("Item ID is required")
                
                val userId = call.getUserId()
                val item = checklistService.getChecklistItem(taskId, itemId)
                call.logWithUser("info", "Retrieved checklist item: $itemId for task: $taskId")
                call.respond(HttpStatusCode.OK, item)
            } catch (e: Exception) {
                if (e.message == "Checklist item not found") {
                    call.respondNotFound("Checklist item not found")
                } else {
                    call.logWithUser("error", "Failed to retrieve checklist item: ${e.message}")
                    call.respondInternalError("Failed to retrieve checklist item")
                }
            }
        }
    }
}
