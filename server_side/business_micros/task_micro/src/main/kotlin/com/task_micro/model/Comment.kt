package com.task_micro.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.Contextual
import java.time.Instant
import java.util.UUID

@Serializable
data class Comment(
    val id: String = UUID.randomUUID().toString(),
    val authorId: String,
    val content: String,
    @Contextual val editedAt: Instant? = null,
    @Contextual val createdAt: Instant = Instant.now(),
    @Contextual val updatedAt: Instant = Instant.now()
)
