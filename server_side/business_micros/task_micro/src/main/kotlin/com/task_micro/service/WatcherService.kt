package com.task_micro.service

import com.task_micro.model.Watcher
import com.task_micro.model.Task
import kotlinx.coroutines.*
import org.litote.kmongo.coroutine.CoroutineDatabase
import org.litote.kmongo.coroutine.CoroutineCollection
import org.litote.kmongo.eq
import org.bson.Document
import java.time.Instant

class WatcherService(private val database: CoroutineDatabase) {
    private val collection: CoroutineCollection<Task> = database.getCollection()

    // Add watcher to task
    suspend fun addWatcher(taskId: String, contactId: String): String = withContext(Dispatchers.IO) {
        val task = collection.findOne(Task::_id eq taskId)
            ?: throw Exception("Task not found")
        
        // Check if watcher already exists
        if (task.watchers.any { it.contactId == contactId }) {
            throw Exception("Watcher already exists")
        }
        
        val newWatcher = Watcher(contactId = contactId, addedAt = Instant.now())
        val updatedWatchers = task.watchers + newWatcher
        
        val updateDoc = Document()
        updateDoc["\$set"] = Document().apply {
            put("watchers", updatedWatchers.map { watcher ->
                Document().apply {
                    put("contactId", watcher.contactId)
                    put("addedAt", watcher.addedAt)
                }
            })
        }
        
        val result = collection.updateOne(
            Task::_id eq taskId,
            updateDoc
        )
        
        if (result.matchedCount == 0L) {
            throw Exception("Task not found")
        }
        
        contactId
    }

    // Remove watcher from task
    suspend fun removeWatcher(taskId: String, contactId: String) = withContext(Dispatchers.IO) {
        val task = collection.findOne(Task::_id eq taskId)
            ?: throw Exception("Task not found")
        
        val updatedWatchers = task.watchers.filter { it.contactId != contactId }
        
        if (updatedWatchers.size == task.watchers.size) {
            throw Exception("Watcher not found")
        }
        
        val updateDoc = Document()
        updateDoc["\$set"] = Document().apply {
            put("watchers", updatedWatchers.map { watcher ->
                Document().apply {
                    put("contactId", watcher.contactId)
                    put("addedAt", watcher.addedAt)
                }
            })
        }
        
        val result = collection.updateOne(
            Task::_id eq taskId,
            updateDoc
        )
        
        if (result.matchedCount == 0L) {
            throw Exception("Task not found")
        }
    }

    // Get watchers for a task
    suspend fun getWatchersForTask(taskId: String): List<Watcher> = withContext(Dispatchers.IO) {
        val task = collection.findOne(Task::_id eq taskId)
            ?: throw Exception("Task not found")
        
        task.watchers
    }

    // Get tasks where user is watcher
    suspend fun getTasksForWatcher(contactId: String): List<String> = withContext(Dispatchers.IO) {
        collection.find(
            Document("watchers.contactId", contactId)
        ).toList().map { it._id }
    }

    // Check if user is watcher for task
    suspend fun isWatcher(taskId: String, contactId: String): Boolean = withContext(Dispatchers.IO) {
        val task = collection.findOne(Task::_id eq taskId)
        task?.watchers?.any { it.contactId == contactId } ?: false
    }
}