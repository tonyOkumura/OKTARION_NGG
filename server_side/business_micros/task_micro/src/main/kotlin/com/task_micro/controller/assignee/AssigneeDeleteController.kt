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

fun Application.configureAssigneeDeleteRouting(database: CoroutineDatabase) {
    val assigneeService = AssigneeService(database)

    routing {
        // Remove assignee from task
        delete("/assignees/{taskId}/{contactId}") {
            try {
                val taskId = call.parameters["taskId"]
                    ?: throw IllegalArgumentException("Task ID is required")
                
                val contactId = call.parameters["contactId"]
                    ?: throw IllegalArgumentException("Contact ID is required")
                
                val userId = call.getUserId()
                assigneeService.removeAssignee(taskId, contactId)
                call.logWithUser("info", "Assignee removed from task $taskId: $contactId")
                call.respond(HttpStatusCode.OK, mapOf("message" to "Assignee removed successfully"))
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid request")
            } catch (e: Exception) {
                if (e.message == "Assignee not found") {
                    call.respondNotFound("Assignee not found")
                } else {
                    call.logWithUser("error", "Failed to remove assignee: ${e.message}")
                    call.respondInternalError("Failed to remove assignee")
                }
            }
        }
    }
}
