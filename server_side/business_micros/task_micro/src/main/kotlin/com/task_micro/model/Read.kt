package com.task_micro.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.Contextual
import java.time.Instant

@Serializable
data class Read(
    val contactId: String,
    @Contextual val lastViewedAt: Instant = Instant.now()
)
