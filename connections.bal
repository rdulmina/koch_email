import ballerina/email;
import ballerinax/kafka;

// Kafka producer for publishing shipment events
kafka:Producer kafkaProducer = check new (bootstrapServers = kafkaBootstrapServers);

// SMTP client for sending emails
email:SmtpClient smtpClient = check new (
    host = smtpHost,
    username = smtpUsername,
    password = smtpPassword
);