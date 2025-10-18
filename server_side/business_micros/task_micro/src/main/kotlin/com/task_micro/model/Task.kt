package com.task_micro.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.Contextual
import java.time.Instant
import java.util.UUID

@Serializable
data class Task(
    val _id: String = UUID.randomUUID().toString(),
    val title: String,
    val description: String? = null,
    val status: String = "open",
    val priority: Int = 3,
    val creatorId: String? = null,
    @Contextual val dueDate: Instant? = null,
    @Contextual val completedAt: Instant? = null,
    @Contextual val createdAt: Instant = Instant.now(),
    @Contextual val updatedAt: Instant = Instant.now(),
    @Contextual val lastActivityAt: Instant = Instant.now(),

    val assignees: List<Assignee> = emptyList(),
    val watchers: List<Watcher> = emptyList(),
    val comments: List<Comment> = emptyList(),
    val attachments: List<Attachment> = emptyList(),
    val checklistItems: List<ChecklistItem> = emptyList(),
    val reads: List<Read> = emptyList()
)
