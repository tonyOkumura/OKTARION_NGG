package com.task_micro.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.Contextual
import java.time.Instant

@Serializable
data class Assignee(
    val contactId: String,
    @Contextual val addedAt: Instant = Instant.now()
)
