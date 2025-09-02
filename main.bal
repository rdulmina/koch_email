import ballerina/http;
import ballerina/log;
import ballerinax/kafka;
import ballerina/io;

// HTTP service for receiving shipment data
service / on new http:Listener(httpPort) {

    // POST endpoint to receive shipment data and publish to Kafka
    resource function post email(@http:Payload ShipmentPayload payload) returns json|http:BadRequest|http:InternalServerError {

        // Validate required fields
        if payload.customerId.trim() == "" || payload.shipmentId.trim() == "" {
            return <http:BadRequest>{
                body: {
                    "error": "customerId and shipmentId are required"
                }
            };
        }

        if payload.products.length() == 0 {
            return <http:BadRequest>{
                body: {
                    "error": "At least one product is required"
                }
            };
        }
        io:print("Valid shipment data received");
        // Publish event to Kafka
        error? publishResult = publishShipmentEvent(payload);
        if publishResult is error {
            log:printError("Failed to publish shipment event", 'error = publishResult);
            return <http:InternalServerError>{
                body: {
                    "error": "Failed to process shipment data"
                }
            };
        }

        return {
            "message": "Shipment data received and processed successfully",
            "shipmentId": payload.shipmentId,
            "status": "received"
        };
    }
}

// Kafka service to consume shipment messages and send emails
service on new kafka:Listener(
    bootstrapServers = kafkaBootstrapServers,
    groupId = "shipment-email-service",
    topics = [kafkaTopic]
) {

    remote function onConsumerRecord(ShipmentMessage[] records) returns error? {
        foreach var recordValue in records {
            // anydata recordValue = consumerRecord.value;
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
