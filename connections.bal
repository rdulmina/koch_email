import ballerina/email;
import ballerinax/kafka;

// Kafka producer configuration with SSL for Aiven
kafka:ProducerConfiguration producerConfig = {
    securityProtocol: kafka:PROTOCOL_SSL,
    secureSocket: {
        cert: kafkaCaCertPath,
        key: {
            certFile: kafkaClientCertPath,
            keyFile: kafkaClientKeyPath
        },
        protocol: {
            name: "TLS"
        }
    }
};

// Kafka producer for publishing shipment events
kafka:Producer kafkaProducer = check new (
    bootstrapServers = kafkaBootstrapServers,
    config = producerConfig
);

// SMTP client for sending emails
email:SmtpClient smtpClient = check new (
    host = smtpHost,
    username = smtpUsername,
    password = smtpPassword
);