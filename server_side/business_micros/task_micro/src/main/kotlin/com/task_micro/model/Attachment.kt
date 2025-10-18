package com.task_micro.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.Contextual
import java.time.Instant
import java.util.UUID

@Serializable
data class Attachment(
    val id: String = UUID.randomUUID().toString(),
    val fileId: String,
    val uploadedBy: String,
    @Contextual val uploadedAt: Instant = Instant.now()
)
