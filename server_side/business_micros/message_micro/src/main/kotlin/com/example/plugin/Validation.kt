package com.example.plugin

import com.example.model.City
import com.example.model.ValidationError
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.plugins.requestvalidation.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import kotlinx.serialization.Serializable

// City data class is defined in CitySchema.kt

fun Application.configureValidation() {
    install(RequestValidation) {
        validate<City> { city ->
            val errors = validateCity(city)
            if (errors.isEmpty()) {
                ValidationResult.Valid
            } else {
                ValidationResult.Invalid(errors.joinToString(", ") { "${it.field}: ${it.message}" })
            }
        }
    }
}

// Функция валидации города с возвратом структурированных ошибок
fun validateCity(city: City): List<ValidationError> {
    val errors = mutableListOf<ValidationError>()
    
    if (city.name.isBlank()) {
        errors.add(ValidationError("name", "City name cannot be blank"))
    } else if (city.name.length > 255) {
        errors.add(ValidationError("name", "City name cannot exceed 255 characters"))
    } else if (!city.name.matches(Regex("^[a-zA-Z\\s\\-']+$"))) {
        errors.add(ValidationError("name", "City name contains invalid characters"))
    }
    
    if (city.country.isBlank()) {
        errors.add(ValidationError("country", "Country cannot be blank"))
    } else if (city.country.length > 255) {
        errors.add(ValidationError("country", "Country cannot exceed 255 characters"))
    } else if (!city.country.matches(Regex("^[a-zA-Z\\s\\-']+$"))) {
        errors.add(ValidationError("country", "Country contains invalid characters"))
    }
    
    if (city.population < 0) {
        errors.add(ValidationError("population", "Population cannot be negative"))
    } else if (city.population > 100_000_000) {
        errors.add(ValidationError("population", "Population cannot exceed 100 million"))
    }
    
    return errors
}

// Custom validation functions
fun validateCityName(name: String): ValidationResult {
    return when {
        name.isBlank() -> ValidationResult.Invalid("City name is required")
        name.length > 255 -> ValidationResult.Invalid("City name cannot exceed 255 characters")
        !name.matches(Regex("^[a-zA-Z\\s\\-']+$")) -> ValidationResult.Invalid("City name contains invalid characters")
        else -> ValidationResult.Valid
    }
}

fun validateCountry(country: String): ValidationResult {
    return when {
        country.isBlank() -> ValidationResult.Invalid("Country is required")
        country.length > 255 -> ValidationResult.Invalid("Country cannot exceed 255 characters")
        !country.matches(Regex("^[a-zA-Z\\s\\-']+$")) -> ValidationResult.Invalid("Country contains invalid characters")
        else -> ValidationResult.Valid
    }
}

fun validatePopulation(population: Int): ValidationResult {
    return when {
        population < 0 -> ValidationResult.Invalid("Population cannot be negative")
        population > 100_000_000 -> ValidationResult.Invalid("Population cannot exceed 100 million")
        else -> ValidationResult.Valid
    }
}
