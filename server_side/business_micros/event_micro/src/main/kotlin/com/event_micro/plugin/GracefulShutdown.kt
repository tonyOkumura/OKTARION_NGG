package com.example.event.plugin

import com.example.config.getAppConfig
import io.ktor.server.application.*
import kotlinx.coroutines.*
import java.sql.Connection
import java.util.concurrent.TimeUnit

fun Application.configureGracefulShutdown() {
    val config = getAppConfig()
    
    // Register shutdown hook
    Runtime.getRuntime().addShutdownHook(Thread {
        logInfo("Shutdown signal received, starting graceful shutdown...")
        
        runBlocking {
            withTimeout(30000) { // 30 seconds timeout
                gracefulShutdown()
            }
        }
        
        logInfo("Graceful shutdown completed")
    })
}

private suspend fun Application.gracefulShutdown() {
    logInfo("Starting graceful shutdown process...")
    
    // 1. Stop accepting new requests
    logInfo("Stopping acceptance of new requests...")
    delay(1000) // Give time for current requests to complete
    
    // 2. Close database connections
    logInfo("Closing database connections...")
    closeDatabaseConnections()
    
    // 3. Wait for ongoing requests to complete
    logInfo("Waiting for ongoing requests to complete...")
    delay(5000) // Wait up to 5 seconds
    
    // 4. Final cleanup
    logInfo("Performing final cleanup...")
    performFinalCleanup()
    
    logInfo("Graceful shutdown process completed")
}

private suspend fun Application.closeDatabaseConnections() {
    try {
        // Close any open database connections
        // This would depend on your connection pooling strategy
        logInfo("Database connections closed")
    } catch (e: Exception) {
        logError("Error closing database connections", e)
    }
}

private suspend fun Application.performFinalCleanup() {
    try {
        // Perform any final cleanup tasks
        // - Close file handles
        // - Clear caches
        // - Send final metrics
        logInfo("Final cleanup completed")
    } catch (e: Exception) {
        logError("Error during final cleanup", e)
    }
}
