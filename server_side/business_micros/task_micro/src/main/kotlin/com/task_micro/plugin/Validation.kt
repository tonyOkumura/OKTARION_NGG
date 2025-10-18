package com.task_micro.plugin

import com.task_micro.model.Task
import com.task_micro.model.ValidationError
import io.ktor.server.application.*
import io.ktor.server.plugins.requestvalidation.*

fun Application.configureValidation() {
    install(RequestValidation) {
        // Task validation is handled manually in controllers after setting creatorId
        // validate<Task> { task ->
        //     val errors = validateTask(task)
        //     if (errors.isEmpty()) {
        //         ValidationResult.Valid
        //     } else {
        //         ValidationResult.Invalid(errors.joinToString(", ") { "${it.field}: ${it.message}" })
        //     }
        // }
    }
}

// Функция валидации задачи с возвратом структурированных ошибок
fun validateTask(task: Task): List<ValidationError> {
    val errors = mutableListOf<ValidationError>()
    
    if (task.title.isBlank()) {
        errors.add(ValidationError("title", "Task title cannot be blank"))
    } else if (task.title.length > 200) {
        errors.add(ValidationError("title", "Task title cannot exceed 200 characters"))
    }
    
    if (task.description != null && task.description.length > 2000) {
        errors.add(ValidationError("description", "Task description cannot exceed 2000 characters"))
    }
    
    if (task.priority !in 1..5) {
        errors.add(ValidationError("priority", "Priority must be between 1 and 5"))
    }
    
    if (task.status !in listOf("open", "in_progress", "completed", "cancelled")) {
        errors.add(ValidationError("status", "Status must be one of: open, in_progress, completed, cancelled"))
    }
    
    if (task.creatorId.isNullOrBlank()) {
        errors.add(ValidationError("creatorId", "Creator ID cannot be blank"))
    }
    
    return errors
}

// Custom validation functions
fun validateTaskTitle(title: String): ValidationResult {
    return when {
        title.isBlank() -> ValidationResult.Invalid("Task title is required")
        title.length > 200 -> ValidationResult.Invalid("Task title cannot exceed 200 characters")
        else -> ValidationResult.Valid
    }
}

fun validateTaskDescription(description: String?): ValidationResult {
    return when {
        description == null -> ValidationResult.Valid
        description.length > 2000 -> ValidationResult.Invalid("Task description cannot exceed 2000 characters")
        else -> ValidationResult.Valid
    }
}

fun validateTaskPriority(priority: Int): ValidationResult {
    return when {
        priority !in 1..5 -> ValidationResult.Invalid("Priority must be between 1 and 5")
        else -> ValidationResult.Valid
    }
}

fun validateTaskStatus(status: String): ValidationResult {
    return when {
        status !in listOf("open", "in_progress", "completed", "cancelled") -> ValidationResult.Invalid("Status must be one of: open, in_progress, completed, cancelled")
        else -> ValidationResult.Valid
    }
}

fun validateCreatorId(creatorId: String?): ValidationResult {
    return when {
        creatorId.isNullOrBlank() -> ValidationResult.Invalid("Creator ID is required")
        else -> ValidationResult.Valid
    }
}