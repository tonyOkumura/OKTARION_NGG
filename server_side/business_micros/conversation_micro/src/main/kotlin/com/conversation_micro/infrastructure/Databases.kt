package com.conversation_micro.infrastructure

import com.conversation_micro.config.getAppConfig
import com.conversation_micro.controller.configureConversationRouting
import com.conversation_micro.controller.configureParticipantRouting
import io.ktor.server.application.*
import java.sql.Connection
import java.sql.DriverManager

fun Application.configureDatabases() {
    val dbConnection: Connection = connectToPostgres(embedded = false)
    val config = getAppConfig()
    
    // Configure conversation routing with database connection and pagination config
    configureConversationRouting(dbConnection, config.pagination)
    
    // Configure participant routing with database connection
    configureParticipantRouting(dbConnection)
    
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
 * Makes a connection to a Postgres database.
 *
 * In order to connect to your running Postgres process,
 * please specify the following parameters in your configuration file:
 * - postgres.url -- Url of your running database process.
 * - postgres.user -- Username for database connection
 * - postgres.password -- Password for database connection
 *
 * If you don't have a database process running yet, you may need to [download]((https://www.postgresql.org/download/))
 * and install Postgres and follow the instructions [here](https://postgresapp.com/).
 * Then, you would be able to edit your url,  which is usually "jdbc:postgresql://host:port/database", as well as
 * user and password values.
 *
 *
 * @param embedded -- if [true] defaults to an embedded database for tests that runs locally in the same process.
 * In this case you don't have to provide any parameters in configuration file, and you don't have to run a process.
 *
 * @return [Connection] that represent connection to the database. Please, don't forget to close this connection when
 * your application shuts down by calling [Connection.close]
 * */
fun Application.connectToPostgres(embedded: Boolean): Connection {
    Class.forName("org.postgresql.Driver")
    if (embedded) {
        log.info("Using embedded H2 database for testing; replace this flag to use postgres")
        return DriverManager.getConnection("jdbc:h2:mem:test;DB_CLOSE_DELAY=-1", "root", "")
    } else {
        val config = getAppConfig()
        log.info("Connecting to postgres database at ${config.database.url}")
        return DriverManager.getConnection(config.database.url, config.database.user, config.database.password)
    }
}
