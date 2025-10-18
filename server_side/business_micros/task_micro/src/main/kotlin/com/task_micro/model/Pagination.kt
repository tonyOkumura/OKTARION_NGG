package com.task_micro.model

import kotlinx.serialization.Serializable

@Serializable
data class PaginatedResponse<T>(
    val data: List<T>,
    val pagination: PaginationInfo
)

@Serializable
data class PaginationInfo(
    val limit: Int,
    val cursor: String? = null,
    val hasMore: Boolean = false,
    val total: Int? = null
)

@Serializable
data class TaskQueryParams(
    val search: String? = null,
    val cursor: String? = null,
    val limit: Int? = null,
    val ids: List<String>? = null
)
