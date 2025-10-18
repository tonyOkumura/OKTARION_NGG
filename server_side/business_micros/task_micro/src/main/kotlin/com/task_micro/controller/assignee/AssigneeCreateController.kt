package com.task_micro.controller.assignee

import com.task_micro.service.AssigneeService
import com.task_micro.plugin.respondInternalError
import com.task_micro.plugin.respondNotFound
import com.task_micro.plugin.respondBadRequest
import com.task_micro.plugin.getUserId
import com.task_micro.plugin.logWithUser
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.litote.kmongo.coroutine.CoroutineDatabase

fun Application.configureAssigneeCreateRouting(database: CoroutineDatabase) {
    val assigneeService = AssigneeService(database)

    routing {
        // Add assignee to task
        post("/assignees/{taskId}") {
            try {
                val taskId = call.parameters["taskId"]
                    ?: throw IllegalArgumentException("Task ID is required")
                
                val userId = call.getUserId()
                val requestData = call.receive<Map<String, String>>()
                val contactId = requestData["contactId"]
                    ?: throw IllegalArgumentException("Contact ID is required")
                
                val assigneeId = assigneeService.addAssignee(taskId, contactId)
                call.logWithUser("info", "Assignee added to task $taskId: $contactId")
                call.respond(HttpStatusCode.Created, mapOf("id" to assigneeId, "taskId" to taskId, "contactId" to contactId))
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid request")
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to add assignee: ${e.message}")
                call.respondInternalError("Failed to add assignee")
            }
        }
    }
}
