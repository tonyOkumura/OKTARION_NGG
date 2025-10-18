package com.task_micro.controller.assignee

import com.task_micro.service.AssigneeService
import com.task_micro.plugin.respondInternalError
import com.task_micro.plugin.respondNotFound
import com.task_micro.plugin.getUserId
import com.task_micro.plugin.logWithUser
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.litote.kmongo.coroutine.CoroutineDatabase

fun Application.configureAssigneeReadRouting(database: CoroutineDatabase) {
    val assigneeService = AssigneeService(database)

    routing {
        // Get assignees for a task
        get("/assignees/{taskId}") {
            try {
                val taskId = call.parameters["taskId"]
                    ?: throw IllegalArgumentException("Task ID is required")
                
                val userId = call.getUserId()
                val assignees = assigneeService.getAssigneesForTask(taskId)
                call.logWithUser("info", "Retrieved ${assignees.size} assignees for task $taskId")
                call.respond(HttpStatusCode.OK, assignees)
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to retrieve assignees: ${e.message}")
                call.respondInternalError("Failed to retrieve assignees")
            }
        }

        // Get tasks where user is assignee
        get("/my-assignments") {
            try {
                val userId = call.getUserId()
                val taskIds = assigneeService.getTasksForAssignee(userId ?: throw IllegalArgumentException("User ID is required"))
                call.logWithUser("info", "Retrieved ${taskIds.size} assigned tasks for user $userId")
                call.respond(HttpStatusCode.OK, mapOf<String, List<String>>("taskIds" to taskIds))
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to retrieve assigned tasks: ${e.message}")
                call.respondInternalError("Failed to retrieve assigned tasks")
            }
        }
    }
}
