import ballerina/log;
import ballerinax/kafka;

// Kafka service to consume shipment messages and send emails
service on new kafka:Listener(
    bootstrapServers = kafkaBootstrapServers,
    groupId = "shipment-email-service",
    topics = [kafkaTopic],
    securityProtocol = kafka:PROTOCOL_SSL,
    secureSocket = {
        cert: kafkaCaCertPath,
        key: {
            certFile: kafkaClientCertPath,
            keyFile: kafkaClientKeyPath
        },
        protocol: {
            name: "TLS"
        }
    }
) {

    remote function onConsumerRecord(ShipmentMessage[] records) returns error? {
        foreach var recordValue in records {
            ShipmentMessage message = check recordValue.cloneWithType(ShipmentMessage);

            log:printInfo("Processing shipment message", shipmentId = message.shipmentId);

            // Send email notification
            error? emailResult = sendShipmentNotification(message);
            if emailResult is error {
                log:printError("Failed to send email notification",
                        'error = emailResult,
                        shipmentId = message.shipmentId
                );
                return emailResult;
            }
        }
    }

    remote function onError(kafka:Error kafkaError) returns error? {
        log:printError("Kafka consumer error occurred", 'error = kafkaError);
    }
}