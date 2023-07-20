import { SQSClient, SendMessageCommand } from "@aws-sdk/client-sqs";
import { v4 as uuidv4 } from "uuid";

const sqs = new SQSClient({ region: "ap-northeast-2" });

const accountId = process.env.OWNER
const orderQueue = process.env.QUEUE_NAME

export const handler = async (event) => {
  try {
    const requestBody = JSON.parse(event.body);
    const randomUUID = uuidv4();
    requestBody.orderNo = randomUUID;
    const orderObj = requestBody;

    console.log("------------------------------------------");
    console.log("event: ", event);
    console.log("------------------------------------------");
    console.log("requestBody: ", requestBody);
    console.log("------------------------------------------");

    const message = JSON.stringify(orderObj);

    // Prepare the message parameters
    const params = {
      MessageBody: message,
      QueueUrl:
        `https://sqs.ap-northeast-2.amazonaws.com/${accountId}/${orderQueue}`,
    };

    // Send the message to the SQS queue
    const result = await sqs.send(new SendMessageCommand(params));
    console.info("Message sent to SQS - Message sent:", result.MessageId);

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET,POST,PUT,DELETE,OPTIONS",
      },
      body: message,
    };
  } catch (error) {
    console.error("Error sending message:", error);
    return {
      statusCode: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"  // CORS 설정
      },
      body: JSON.stringify({ error: "Error sending message to SQS" })
    };
  }
};
