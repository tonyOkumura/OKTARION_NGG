package com.task_micro.infrastructure

import com.task_micro.config.getAppConfig
import com.task_micro.controller.configureTaskCreateRouting
import com.task_micro.controller.configureTaskReadRouting
import com.task_micro.controller.configureTaskUpdateRouting
import com.task_micro.controller.configureTaskDeleteRouting
import com.task_micro.controller.assignee.configureAssigneeCreateRouting
import com.task_micro.controller.assignee.configureAssigneeReadRouting
import com.task_micro.controller.assignee.configureAssigneeDeleteRouting
import com.task_micro.controller.watcher.configureWatcherCreateRouting
import com.task_micro.controller.watcher.configureWatcherReadRouting
import com.task_micro.controller.watcher.configureWatcherDeleteRouting
import com.task_micro.controller.checklist.configureChecklistCreateRouting
import com.task_micro.controller.checklist.configureChecklistReadRouting
import com.task_micro.controller.checklist.configureChecklistUpdateRouting
import com.task_micro.controller.checklist.configureChecklistDeleteRouting
import io.ktor.server.application.*
import org.litote.kmongo.coroutine.coroutine
import org.litote.kmongo.reactivestreams.KMongo

fun Application.configureDatabases() {
    val mongoClient = connectToMongo()
    val database = mongoClient.getDatabase(getAppConfig().database.databaseName)
    
    // Configure task routing with database connection
    configureTaskCreateRouting(database)
    configureTaskReadRouting(database)
    configureTaskUpdateRouting(database)
    configureTaskDeleteRouting(database)
    
    // Configure assignee routing
    configureAssigneeCreateRouting(database)
    configureAssigneeReadRouting(database)
    configureAssigneeDeleteRouting(database)
    
    // Configure watcher routing
    configureWatcherCreateRouting(database)
    configureWatcherReadRouting(database)
    configureWatcherDeleteRouting(database)
    
    // Configure checklist routing
    configureChecklistCreateRouting(database)
    configureChecklistReadRouting(database)
    configureChecklistUpdateRouting(database)
    configureChecklistDeleteRouting(database)
    
    // Kafka configuration temporarily disabled
    // install(Kafka) {
    //     schemaRegistryUrl = "my.schemaRegistryUrl"
    //     val myTopic = TopicName.named("my-topic")
    //     topic(myTopic) {
    //         partitions = 1
    //         replicas = 1
    //         configs {
    //             messageTimestampType = MessageTimestampType.CreateTime
    //         }
    //     }
    //     common { // <-- Define common properties
    //         bootstrapServers = listOf("my-kafka")
    //         retries = 1
    //         clientId = "my-client-id"
    //     }
    //     admin { } // <-- Creates an admin client
    //     producer { // <-- Creates a producer
    //         clientId = "my-client-id"
    //     }
    //     consumer { // <-- Creates a consumer
    //         groupId = "my-group-id"
    //         clientId = "my-client-id-override" //<-- Override common properties
    //     }
    //     consumerConfig {
    //         consumerRecordHandler(myTopic) { record ->
    //             // Do something with record
    //         }
    //     }
    //     registerSchemas {
    //         using { // <-- optionally provide a client, by default CIO is used
    //             HttpClient()
    //         }
    //         // MyRecord::class at myTopic // <-- Will register schema upon startup
    //     }
    // }
}

/**
 * Makes a connection to a MongoDB database.
 *
 * In order to connect to your running MongoDB process,
 * please specify the following parameters in your configuration file:
 * - mongodb.connectionString -- Connection string to your running MongoDB process.
 * - mongodb.database -- Database name
 *
 * If you don't have a database process running yet, you may need to [download](https://www.mongodb.com/try/download/community)
 * and install MongoDB and follow the instructions [here](https://docs.mongodb.com/manual/installation/).
 * Then, you would be able to edit your connection string, which is usually "mongodb://host:port", as well as
 * database name.
 *
 * @return [CoroutineClient] that represent connection to the database. Please, don't forget to close this connection when
 * your application shuts down by calling [CoroutineClient.close]
 * */
fun Application.connectToMongo() = KMongo.createClient(getAppConfig().database.connectionString).coroutine
