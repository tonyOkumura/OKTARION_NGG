package com.task_micro.service

import com.task_micro.model.Task
import com.task_micro.model.TaskQueryParams
import com.task_micro.model.PaginatedResponse
import com.task_micro.model.PaginationInfo
import kotlinx.coroutines.*
import org.litote.kmongo.coroutine.CoroutineDatabase
import org.litote.kmongo.coroutine.CoroutineCollection
import org.litote.kmongo.eq
import org.litote.kmongo.regex
import org.litote.kmongo.setValue
import org.litote.kmongo.set
import org.litote.kmongo.and
import org.litote.kmongo.inc
import org.litote.kmongo.currentDate
import org.litote.kmongo.`in`
import org.litote.kmongo.gt
import org.litote.kmongo.gte
import org.bson.Document
import java.time.Instant
import java.util.UUID

class TaskService(private val database: CoroutineDatabase) {
    private val collection: CoroutineCollection<Task> = database.getCollection()

    // Create new task
    suspend fun create(task: Task): String = withContext(Dispatchers.IO) {
        val taskWithId = task.copy(_id = UUID.randomUUID().toString())
        collection.insertOne(taskWithId)
        taskWithId._id ?: throw Exception("Unable to retrieve the id of the newly inserted task")
    }

    // Read a task by ID and creator (security check)
    suspend fun readByCreator(id: String, creatorId: String): Task = withContext(Dispatchers.IO) {
        collection.findOne(and(Task::_id eq id, Task::creatorId eq creatorId))
            ?: throw Exception("Task not found or access denied")
    }

    // Update a task (only if user is creator)
    suspend fun updateByCreator(id: String, task: Task, creatorId: String) = withContext(Dispatchers.IO) {
        val updatedTask = task.copy(
            _id = id,
            creatorId = creatorId, // Ensure creatorId is preserved
            updatedAt = Instant.now(),
            lastActivityAt = Instant.now()
        )
        val result = collection.replaceOne(and(Task::_id eq id, Task::creatorId eq creatorId), updatedTask)
        if (result.matchedCount == 0L) {
            throw Exception("Task not found or access denied")
        }
    }

    // Delete a task (only if user is creator)
    suspend fun deleteByCreator(id: String, creatorId: String) = withContext(Dispatchers.IO) {
        val result = collection.deleteOne(and(Task::_id eq id, Task::creatorId eq creatorId))
        if (result.deletedCount == 0L) {
            throw Exception("Task not found or access denied")
        }
    }

    // Update task status (only if user is creator)
    suspend fun updateStatusByCreator(id: String, status: String, creatorId: String) = withContext(Dispatchers.IO) {
        val now = Instant.now()
        val updateDoc = Document()
        updateDoc["\$set"] = Document().apply {
            put("status", status)
            put("updatedAt", now)
            put("lastActivityAt", now)
            if (status == "completed") {
                put("completedAt", now)
            }
        }
        
        val result = collection.updateOne(
            and(Task::_id eq id, Task::creatorId eq creatorId),
            updateDoc
        )
        if (result.matchedCount == 0L) {
            throw Exception("Task not found or access denied")
        }
    }

    // Update task priority (only if user is creator)
    suspend fun updatePriorityByCreator(id: String, priority: Int, creatorId: String) = withContext(Dispatchers.IO) {
        val now = Instant.now()
        val updateDoc = Document()
        updateDoc["\$set"] = Document().apply {
            put("priority", priority)
            put("updatedAt", now)
            put("lastActivityAt", now)
        }
        
        val result = collection.updateOne(
            and(Task::_id eq id, Task::creatorId eq creatorId),
            updateDoc
        )
        if (result.matchedCount == 0L) {
            throw Exception("Task not found or access denied")
        }
    }

    // Get all tasks for user (as creator, assignee, or watcher) with pagination and search
    suspend fun getAllTasksForUserPaginated(userId: String, queryParams: TaskQueryParams, defaultLimit: Int, maxLimit: Int): PaginatedResponse<Task> = withContext(Dispatchers.IO) {
        val limit = minOf(queryParams.limit ?: defaultLimit, maxLimit)
        
        // Build MongoDB query to find tasks where user is creator, assignee, or watcher
        val query = Document().apply {
            put("\$or", listOf(
                Document("creatorId", userId),
                Document("assignees.contactId", userId),
                Document("watchers.contactId", userId)
            ))
        }
        
        // Get all tasks for user using single query
        var allTasks = collection.find(query).toList()
        
        // Apply search filter
        if (!queryParams.search.isNullOrBlank()) {
            val searchTerm = queryParams.search.lowercase()
            allTasks = allTasks.filter { task ->
                task.title.lowercase().contains(searchTerm) ||
                task.description?.lowercase()?.contains(searchTerm) == true
            }
        }
        
        // Apply ID filter
        if (!queryParams.ids.isNullOrEmpty()) {
            allTasks = allTasks.filter { task -> task._id in queryParams.ids }
        }
        
        // Sort by createdAt descending
        allTasks = allTasks.sortedByDescending { it.createdAt }
        
        // Apply cursor-based pagination
        val cursorInstant = queryParams.cursor?.let { 
            try { Instant.parse(it) } catch (e: Exception) { null }
        }
        
        if (cursorInstant != null) {
            allTasks = allTasks.filter { it.createdAt < cursorInstant }
        }
        
        // Apply limit and check if there are more items
        val hasMore = allTasks.size > limit
        val paginatedTasks = allTasks.take(limit)
        
        // Get next cursor
        val nextCursor = if (hasMore && paginatedTasks.isNotEmpty()) {
            paginatedTasks.last().createdAt.toString()
        } else null
        
        PaginatedResponse(
            data = paginatedTasks,
            pagination = PaginationInfo(
                limit = limit,
                cursor = nextCursor,
                hasMore = hasMore,
                total = allTasks.size
            )
        )
    }

    // Get tasks by status and creator
    suspend fun getByStatusAndCreator(status: String, creatorId: String): List<Task> = withContext(Dispatchers.IO) {
        collection.find(and(Task::status eq status, Task::creatorId eq creatorId)).toList()
    }

    // Get tasks by priority and creator
    suspend fun getByPriorityAndCreator(priority: Int, creatorId: String): List<Task> = withContext(Dispatchers.IO) {
        collection.find(and(Task::priority eq priority, Task::creatorId eq creatorId)).toList()
    }

    // Search tasks by title and creator
    suspend fun searchByTitleAndCreator(titleQuery: String, creatorId: String): List<Task> = withContext(Dispatchers.IO) {
        collection.find(and(Task::title regex titleQuery, Task::creatorId eq creatorId)).toList()
    }
}
