import ballerina/log;

// Function to generate email content for shipment
public function generateShipmentEmail(ShipmentMessage message) returns string {
    string productList = "";
    foreach Product product in message.products {
        productList += string `- ${product.productCode}: ${product.qty} units ${"\n"}`;
    }

    return string `
            Dear Customer,

            Your shipment has been received and is being processed.

            Shipment Details:
            - Shipment ID: ${message.shipmentId}
            - Customer ID: ${message.customerId}
            - Shipment Date: ${message.shipmentDate}
            - Status: ${message.status}

            Products:
            ${productList}

            We will notify you once your shipment is ready for delivery.

            Best regards,
            Koch Invoice Team
                `;
}

// Function to send shipment notification email
public function sendShipmentNotification(ShipmentMessage message) returns error? {
    string emailBody = generateShipmentEmail(message);
    string subject = string `Shipment Received - ${message.shipmentId}`;
    string toAddress = string `dulmina@wso2.com`;

    check smtpClient->send(
        to = toAddress,
        subject = subject,
        'from = smtpUsername,
        body = emailBody
    );

    log:printInfo("Sent shipment notification email",
            shipmentId = message.shipmentId,
            customerId = message.customerId
    );
}