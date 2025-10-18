package com.task_micro.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.Contextual
import java.time.Instant
import java.util.UUID

@Serializable
data class ChecklistItem(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val isCompleted: Boolean = false,
    val completedBy: String? = null,
    @Contextual val completedAt: Instant? = null,
    @Contextual val createdAt: Instant = Instant.now(),
    @Contextual val updatedAt: Instant = Instant.now()
)
