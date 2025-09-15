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
    remote function onConsumerRecord(kafka:AnydataConsumerRecord[] records) returns error? {
        foreach kafka:AnydataConsumerRecord consumerRecord in records {
            // Extract correlation-id from headers
            map<byte[]|byte[][]|string|string[]> headers = consumerRecord.headers;
            string correlationId = "";

            if headers.hasKey("correlation-id") {
                var headerValue = headers["correlation-id"];
                if headerValue is string {
                    correlationId = headerValue;
                } else if headerValue is byte[] {
                    string|error stringValue = string:fromBytes(headerValue);
                    if stringValue is string {
                        correlationId = stringValue;
                    }
                }
            }

            // Handle the message value conversion
            ShipmentMessage shipmentMessage;
            anydata messageValue = consumerRecord.value;
            
            if messageValue is byte[] {
                // Convert byte array to string first
                string jsonString = check string:fromBytes(messageValue);
                
                // Parse JSON string and convert to ShipmentMessage
                json messageJson = check jsonString.fromJsonString();
                shipmentMessage = check messageJson.cloneWithType();
            } else {
                // If it's already structured data, convert directly
                shipmentMessage = check messageValue.cloneWithType();
            }
            
            log:printInfo("Processing shipment message", 
                    shipmentId = shipmentMessage.shipmentId,
                    correlationId = correlationId
            );

            // Send email notification
            error? emailResult = sendShipmentNotification(shipmentMessage, correlationId);
            if emailResult is error {
                log:printError("Failed to send email notification",
                        'error = emailResult,
                        shipmentId = shipmentMessage.shipmentId,
                        correlationId = correlationId
                );
                return emailResult;
            }
        }
    }

    remote function onError(kafka:Error kafkaError) returns error? {
        log:printError("Kafka consumer error occurred", 'error = kafkaError);
    }
}
