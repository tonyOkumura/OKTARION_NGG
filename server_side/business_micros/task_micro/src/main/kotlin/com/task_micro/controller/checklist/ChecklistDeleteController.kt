package com.task_micro.controller.checklist

import com.task_micro.service.ChecklistService
import com.task_micro.plugin.respondInternalError
import com.task_micro.plugin.respondNotFound
import com.task_micro.plugin.respondBadRequest
import com.task_micro.plugin.getUserId
import com.task_micro.plugin.logWithUser
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.litote.kmongo.coroutine.CoroutineDatabase

fun Application.configureChecklistDeleteRouting(database: CoroutineDatabase) {
    val checklistService = ChecklistService(database)

    routing {
        // Remove checklist item from task
        delete("/tasks/{taskId}/checklist/{itemId}") {
            try {
                val taskId = call.parameters["taskId"]
                    ?: throw IllegalArgumentException("Task ID is required")
                
                val itemId = call.parameters["itemId"]
                    ?: throw IllegalArgumentException("Item ID is required")
                
                val userId = call.getUserId()
                checklistService.removeChecklistItem(taskId, itemId)
                call.logWithUser("info", "Checklist item removed from task $taskId: $itemId")
                call.respond(HttpStatusCode.OK, mapOf("message" to "Checklist item removed successfully"))
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid request")
            } catch (e: Exception) {
                if (e.message == "Checklist item not found") {
                    call.respondNotFound("Checklist item not found")
                } else {
                    call.logWithUser("error", "Failed to remove checklist item: ${e.message}")
                    call.respondInternalError("Failed to remove checklist item")
                }
            }
        }
    }
}
