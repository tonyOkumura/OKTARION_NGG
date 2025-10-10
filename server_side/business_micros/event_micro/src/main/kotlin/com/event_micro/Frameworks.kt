package com.example

import com.example.service.GreetingService
import io.ktor.server.application.*
import io.ktor.server.plugins.di.*

fun Application.configureFrameworks() {
    dependencies {
        provide { GreetingService { "Hello, World!" } }
    }
}
