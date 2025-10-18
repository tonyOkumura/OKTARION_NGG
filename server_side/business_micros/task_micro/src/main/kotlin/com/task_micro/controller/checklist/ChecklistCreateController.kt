package com.task_micro.controller.checklist

import com.task_micro.service.ChecklistService
import com.task_micro.plugin.respondInternalError
import com.task_micro.plugin.respondBadRequest
import com.task_micro.plugin.getUserId
import com.task_micro.plugin.logWithUser
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.litote.kmongo.coroutine.CoroutineDatabase

fun Application.configureChecklistCreateRouting(database: CoroutineDatabase) {
    val checklistService = ChecklistService(database)

    routing {
        // Add checklist item to task
        post("/tasks/{taskId}/checklist") {
            try {
                val taskId = call.parameters["taskId"]
                    ?: throw IllegalArgumentException("Task ID is required")
                
                val userId = call.getUserId()
                val requestData = call.receive<Map<String, String>>()
                val title = requestData["title"]
                    ?: throw IllegalArgumentException("Title is required")
                
                if (title.isBlank()) {
                    call.respondBadRequest("Title cannot be blank")
                    return@post
                }
                
                val itemId = checklistService.addChecklistItem(taskId, title, userId ?: throw IllegalArgumentException("User ID is required"))
                call.logWithUser("info", "Checklist item added to task $taskId: $title")
                call.respond(HttpStatusCode.Created, mapOf("id" to itemId, "taskId" to taskId, "title" to title))
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid request")
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to add checklist item: ${e.message}")
                call.respondInternalError("Failed to add checklist item")
            }
        }
    }
}
