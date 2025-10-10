plugins {
    alias(libs.plugins.kotlin.jvm)
    alias(libs.plugins.ktor)
    alias(libs.plugins.kotlin.plugin.serialization)
}

group = "com.conversation_micro"
version = "0.0.1"

application {
    mainClass = "com.conversation_micro.ApplicationKt"
}

dependencies {
    implementation(libs.ktor.server.request.validation)
    implementation(libs.ktor.server.default.headers)
    implementation(libs.ktor.server.core)
    implementation(libs.ktor.server.host.common)
    implementation(libs.ktor.server.status.pages)
    implementation(libs.ktor.server.di)
    implementation(libs.ktor.serialization.kotlinx.json)
    implementation(libs.ktor.server.content.negotiation)
    implementation(libs.postgresql)
    implementation(libs.h2)
    // implementation(libs.ktor.server.kafka)  // Temporarily disabled
    // implementation(libs.ktor.client.core)   // Temporarily disabled
    implementation(libs.ktor.server.call.logging)
    implementation(libs.ktor.server.cors)
    implementation(libs.ktor.server.netty)
    implementation(libs.logback.classic)
    // testImplementation(libs.ktor.server.test.host)
    // testImplementation(libs.kotlin.test.junit)
}
