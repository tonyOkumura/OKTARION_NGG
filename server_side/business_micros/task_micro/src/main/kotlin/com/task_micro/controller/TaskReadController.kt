package com.task_micro.controller

import com.task_micro.service.TaskService
import com.task_micro.model.TaskQueryParams
import com.task_micro.config.getAppConfig
import com.task_micro.plugin.respondInternalError
import com.task_micro.plugin.respondBadRequest
import com.task_micro.plugin.respondNotFound
import com.task_micro.plugin.getUserId
import com.task_micro.plugin.logWithUser
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.litote.kmongo.coroutine.CoroutineDatabase

fun Application.configureTaskReadRouting(database: CoroutineDatabase) {
    val taskService = TaskService(database)

    routing {
        // Get tasks by creator (main endpoint for getting user's tasks) with pagination and search
        get {
            try {
                val userId = call.getUserId()
                val config = getAppConfig()
                
                // Parse query parameters
                val search = call.request.queryParameters["search"]
                val cursor = call.request.queryParameters["cursor"]
                val limit = call.request.queryParameters["limit"]?.toIntOrNull()
                val ids = call.request.queryParameters.getAll("ids")
                
                val queryParams = TaskQueryParams(
                    search = search,
                    cursor = cursor,
                    limit = limit,
                    ids = ids
                )
                
                val result = taskService.getAllTasksForUserPaginated(
                    userId ?: throw IllegalArgumentException("User ID is required"),
                    queryParams,
                    config.pagination.defaultLimit,
                    config.pagination.maxLimit
                )
                
                call.logWithUser("info", "Retrieved ${result.data.size} tasks for user $userId (creator, assignee, watcher) with pagination")
                call.respond(HttpStatusCode.OK, result)
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid request")
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to retrieve user tasks: ${e.message}")
                call.respondInternalError("Failed to retrieve user tasks")
            }
        }

        // Get tasks by status (filtered by creator)
        get("/status/{status}") {
            try {
                val status = call.parameters["status"]
                    ?: throw IllegalArgumentException("Status parameter is required")
                
                if (status !in listOf("open", "in_progress", "completed", "cancelled")) {
                    call.respondBadRequest("Invalid status. Must be one of: open, in_progress, completed, cancelled")
                    return@get
                }
                
                val userId = call.getUserId()
                val tasks = taskService.getByStatusAndCreator(status, userId ?: throw IllegalArgumentException("User ID is required"))
                call.logWithUser("info", "Retrieved ${tasks.size} tasks with status: $status for user $userId")
                call.respond(HttpStatusCode.OK, tasks)
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid request")
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to retrieve tasks by status: ${e.message}")
                call.respondInternalError("Failed to retrieve tasks by status")
            }
        }

        // Get tasks by priority (filtered by creator)
        get("/priority/{priority}") {
            try {
                val priorityStr = call.parameters["priority"]
                    ?: throw IllegalArgumentException("Priority parameter is required")
                
                val priority = priorityStr.toIntOrNull()
                    ?: throw IllegalArgumentException("Priority must be a number")
                
                if (priority !in 1..5) {
                    call.respondBadRequest("Priority must be between 1 and 5")
                    return@get
                }
                
                val userId = call.getUserId()
                val tasks = taskService.getByPriorityAndCreator(priority, userId ?: throw IllegalArgumentException("User ID is required"))
                call.logWithUser("info", "Retrieved ${tasks.size} tasks with priority: $priority for user $userId")
                call.respond(HttpStatusCode.OK, tasks)
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid request")
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to retrieve tasks by priority: ${e.message}")
                call.respondInternalError("Failed to retrieve tasks by priority")
            }
        }

        // Search tasks by title (filtered by creator)
        get("/search") {
            try {
                val query = call.request.queryParameters["q"]
                    ?: throw IllegalArgumentException("Search query parameter 'q' is required")
                
                if (query.isBlank()) {
                    call.respondBadRequest("Search query cannot be blank")
                    return@get
                }
                
                val userId = call.getUserId()
                val tasks = taskService.searchByTitleAndCreator(query, userId ?: throw IllegalArgumentException("User ID is required"))
                call.logWithUser("info", "Found ${tasks.size} tasks matching query: $query for user $userId")
                call.respond(HttpStatusCode.OK, tasks)
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid request")
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to search tasks: ${e.message}")
                call.respondInternalError("Failed to search tasks")
            }
        }

        // Get specific task by ID (only if user is creator)
        get("/{id}") {
            try {
                val id = call.parameters["id"]
                    ?: throw IllegalArgumentException("Task ID is required")
                
                val userId = call.getUserId()
                val task = taskService.readByCreator(id, userId ?: throw IllegalArgumentException("User ID is required"))
                call.logWithUser("info", "Retrieved task: $id for user $userId")
                call.respond(HttpStatusCode.OK, task)
            } catch (e: Exception) {
                if (e.message == "Task not found or access denied") {
                    call.respondNotFound("Task not found or access denied")
                } else {
                    call.logWithUser("error", "Failed to retrieve task: ${e.message}")
                    call.respondInternalError("Failed to retrieve task")
                }
            }
        }
    }
}
