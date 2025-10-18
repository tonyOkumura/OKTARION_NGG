package com.task_micro.controller.watcher

import com.task_micro.service.WatcherService
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

fun Application.configureWatcherDeleteRouting(database: CoroutineDatabase) {
    val watcherService = WatcherService(database)

    routing {
        // Remove watcher from task
        delete("/watchers/{taskId}/{contactId}") {
            try {
                val taskId = call.parameters["taskId"]
                    ?: throw IllegalArgumentException("Task ID is required")
                
                val contactId = call.parameters["contactId"]
                    ?: throw IllegalArgumentException("Contact ID is required")
                
                val userId = call.getUserId()
                watcherService.removeWatcher(taskId, contactId)
                call.logWithUser("info", "Watcher removed from task $taskId: $contactId")
                call.respond(HttpStatusCode.OK, mapOf("message" to "Watcher removed successfully"))
            } catch (e: IllegalArgumentException) {
                call.respondBadRequest(e.message ?: "Invalid request")
            } catch (e: Exception) {
                if (e.message == "Watcher not found") {
                    call.respondNotFound("Watcher not found")
                } else {
                    call.logWithUser("error", "Failed to remove watcher: ${e.message}")
                    call.respondInternalError("Failed to remove watcher")
                }
            }
        }
    }
}
