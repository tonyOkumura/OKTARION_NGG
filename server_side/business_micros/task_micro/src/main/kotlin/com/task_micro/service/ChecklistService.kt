package com.task_micro.service

import com.task_micro.model.ChecklistItem
import com.task_micro.model.Task
import kotlinx.coroutines.*
import org.litote.kmongo.coroutine.CoroutineDatabase
import org.litote.kmongo.coroutine.CoroutineCollection
import org.litote.kmongo.eq
import org.bson.Document
import java.time.Instant
import java.util.UUID

class ChecklistService(private val database: CoroutineDatabase) {
    private val collection: CoroutineCollection<Task> = database.getCollection()

    // Add checklist item to task
    suspend fun addChecklistItem(taskId: String, title: String, addedBy: String): String = withContext(Dispatchers.IO) {
        val task = collection.findOne(Task::_id eq taskId)
            ?: throw Exception("Task not found")
        
        val itemId = UUID.randomUUID().toString()
        val newItem = ChecklistItem(
            id = itemId,
            title = title,
            isCompleted = false,
            completedBy = null,
            completedAt = null,
            createdAt = Instant.now(),
            updatedAt = Instant.now()
        )
        
        val updatedItems = task.checklistItems + newItem
        
        val updateDoc = Document()
        updateDoc["\$set"] = Document().apply {
            put("checklistItems", updatedItems.map { item ->
                Document().apply {
                    put("id", item.id)
                    put("title", item.title)
                    put("isCompleted", item.isCompleted)
                    put("completedBy", item.completedBy)
                    put("completedAt", item.completedAt)
                    put("createdAt", item.createdAt)
                    put("updatedAt", item.updatedAt)
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
        
        itemId
    }

    // Update checklist item
    suspend fun updateChecklistItem(taskId: String, itemId: String, title: String?, isCompleted: Boolean?, completedBy: String?) = withContext(Dispatchers.IO) {
        val task = collection.findOne(Task::_id eq taskId)
            ?: throw Exception("Task not found")
        
        val itemIndex = task.checklistItems.indexOfFirst { it.id == itemId }
        if (itemIndex == -1) {
            throw Exception("Checklist item not found")
        }
        
        val existingItem = task.checklistItems[itemIndex]
        val updatedItem = existingItem.copy(
            title = title ?: existingItem.title,
            isCompleted = isCompleted ?: existingItem.isCompleted,
            completedBy = if (isCompleted == true) completedBy else if (isCompleted == false) null else existingItem.completedBy,
            completedAt = if (isCompleted == true) Instant.now() else if (isCompleted == false) null else existingItem.completedAt,
            updatedAt = Instant.now()
        )
        
        val updatedItems = task.checklistItems.toMutableList()
        updatedItems[itemIndex] = updatedItem
        
        val updateDoc = Document()
        updateDoc["\$set"] = Document().apply {
            put("checklistItems", updatedItems.map { item ->
                Document().apply {
                    put("id", item.id)
                    put("title", item.title)
                    put("isCompleted", item.isCompleted)
                    put("completedBy", item.completedBy)
                    put("completedAt", item.completedAt)
                    put("createdAt", item.createdAt)
                    put("updatedAt", item.updatedAt)
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

    // Remove checklist item from task
    suspend fun removeChecklistItem(taskId: String, itemId: String) = withContext(Dispatchers.IO) {
        val task = collection.findOne(Task::_id eq taskId)
            ?: throw Exception("Task not found")
        
        val updatedItems = task.checklistItems.filter { it.id != itemId }
        
        if (updatedItems.size == task.checklistItems.size) {
            throw Exception("Checklist item not found")
        }
        
        val updateDoc = Document()
        updateDoc["\$set"] = Document().apply {
            put("checklistItems", updatedItems.map { item ->
                Document().apply {
                    put("id", item.id)
                    put("title", item.title)
                    put("isCompleted", item.isCompleted)
                    put("completedBy", item.completedBy)
                    put("completedAt", item.completedAt)
                    put("createdAt", item.createdAt)
                    put("updatedAt", item.updatedAt)
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

    // Get checklist items for a task
    suspend fun getChecklistItemsForTask(taskId: String): List<ChecklistItem> = withContext(Dispatchers.IO) {
        val task = collection.findOne(Task::_id eq taskId)
            ?: throw Exception("Task not found")
        
        task.checklistItems
    }

    // Get checklist item by ID
    suspend fun getChecklistItem(taskId: String, itemId: String): ChecklistItem = withContext(Dispatchers.IO) {
        val task = collection.findOne(Task::_id eq taskId)
            ?: throw Exception("Task not found")
        
        task.checklistItems.find { it.id == itemId }
            ?: throw Exception("Checklist item not found")
    }
}