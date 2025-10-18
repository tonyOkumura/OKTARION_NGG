package com.task_micro.service

import com.task_micro.model.Assignee
import com.task_micro.model.Task
import kotlinx.coroutines.*
import org.litote.kmongo.coroutine.CoroutineDatabase
import org.litote.kmongo.coroutine.CoroutineCollection
import org.litote.kmongo.eq
import org.bson.Document
import java.time.Instant

class AssigneeService(private val database: CoroutineDatabase) {
    private val collection: CoroutineCollection<Task> = database.getCollection()

    // Add assignee to task
    suspend fun addAssignee(taskId: String, contactId: String): String = withContext(Dispatchers.IO) {
        val task = collection.findOne(Task::_id eq taskId)
            ?: throw Exception("Task not found")
        
        // Check if assignee already exists
        if (task.assignees.any { it.contactId == contactId }) {
            throw Exception("Assignee already exists")
        }
        
        val newAssignee = Assignee(contactId = contactId, addedAt = Instant.now())
        val updatedAssignees = task.assignees + newAssignee
        
        val updateDoc = Document()
        updateDoc["\$set"] = Document().apply {
            put("assignees", updatedAssignees.map { assignee ->
                Document().apply {
                    put("contactId", assignee.contactId)
                    put("addedAt", assignee.addedAt)
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

    // Remove assignee from task
    suspend fun removeAssignee(taskId: String, contactId: String) = withContext(Dispatchers.IO) {
        val task = collection.findOne(Task::_id eq taskId)
            ?: throw Exception("Task not found")
        
        val updatedAssignees = task.assignees.filter { it.contactId != contactId }
        
        if (updatedAssignees.size == task.assignees.size) {
            throw Exception("Assignee not found")
        }
        
        val updateDoc = Document()
        updateDoc["\$set"] = Document().apply {
            put("assignees", updatedAssignees.map { assignee ->
                Document().apply {
                    put("contactId", assignee.contactId)
                    put("addedAt", assignee.addedAt)
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

    // Get assignees for a task
    suspend fun getAssigneesForTask(taskId: String): List<Assignee> = withContext(Dispatchers.IO) {
        val task = collection.findOne(Task::_id eq taskId)
            ?: throw Exception("Task not found")
        
        task.assignees
    }

    // Get tasks where user is assignee
    suspend fun getTasksForAssignee(contactId: String): List<String> = withContext(Dispatchers.IO) {
        collection.find(
            Document("assignees.contactId", contactId)
        ).toList().map { it._id }
    }

    // Check if user is assignee for task
    suspend fun isAssignee(taskId: String, contactId: String): Boolean = withContext(Dispatchers.IO) {
        val task = collection.findOne(Task::_id eq taskId)
        task?.assignees?.any { it.contactId == contactId } ?: false
    }
}