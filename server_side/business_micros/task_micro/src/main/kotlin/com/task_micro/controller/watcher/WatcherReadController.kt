package com.task_micro.controller.watcher

import com.task_micro.service.WatcherService
import com.task_micro.plugin.respondInternalError
import com.task_micro.plugin.respondNotFound
import com.task_micro.plugin.getUserId
import com.task_micro.plugin.logWithUser
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.litote.kmongo.coroutine.CoroutineDatabase

fun Application.configureWatcherReadRouting(database: CoroutineDatabase) {
    val watcherService = WatcherService(database)

    routing {
        // Get watchers for a task
        get("/watchers/{taskId}") {
            try {
                val taskId = call.parameters["taskId"]
                    ?: throw IllegalArgumentException("Task ID is required")
                
                val userId = call.getUserId()
                val watchers = watcherService.getWatchersForTask(taskId)
                call.logWithUser("info", "Retrieved ${watchers.size} watchers for task $taskId")
                call.respond(HttpStatusCode.OK, watchers)
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to retrieve watchers: ${e.message}")
                call.respondInternalError("Failed to retrieve watchers")
            }
        }

        // Get tasks where user is watcher
        get("/my-watched") {
            try {
                val userId = call.getUserId()
                val taskIds = watcherService.getTasksForWatcher(userId ?: throw IllegalArgumentException("User ID is required"))
                call.logWithUser("info", "Retrieved ${taskIds.size} watched tasks for user $userId")
                call.respond(HttpStatusCode.OK, mapOf<String, List<String>>("taskIds" to taskIds))
            } catch (e: Exception) {
                call.logWithUser("error", "Failed to retrieve watched tasks: ${e.message}")
                call.respondInternalError("Failed to retrieve watched tasks")
            }
        }
    }
}
