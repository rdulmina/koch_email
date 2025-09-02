// Kafka configuration
configurable string kafkaBootstrapServers = "localhost:9092";
configurable string kafkaTopic = "shipments.received.v1";

// Email configuration
configurable string smtpHost = "smtp.gmail.com";
configurable string smtpUsername = "cleanharborspoc@gmail.com";
configurable string smtpPassword = "arsw lebh yfre xpeq";
configurable int smtpPort = 587;

// HTTP configuration
configurable int httpPort = 8080;