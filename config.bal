// Kafka configuration
configurable string kafkaBootstrapServers = "kafka-f5b6556dc0cd4b87be99200bba82070a-kochkafk1277950574-chore.i.aivencloud.com:24549";
configurable string kafkaTopic = "shipments-received-v1";

// Kafka SSL configuration - Add paths to your certificate files
configurable string kafkaCaCertPath = "resources/ca-9c495bac-c192-47e2-b5ac-ef94276f99ca.pem";
configurable string kafkaClientCertPath = "resources/service.cert";
configurable string kafkaClientKeyPath = "resources/service.key";

// Email configuration
configurable string smtpHost = "smtp.gmail.com";
configurable string smtpUsername = "cleanharborspoc@gmail.com";
configurable string smtpPassword = "arsw lebh yfre xpeq";
configurable int smtpPort = 587;

// HTTP configuration
configurable int httpPort = 8080;