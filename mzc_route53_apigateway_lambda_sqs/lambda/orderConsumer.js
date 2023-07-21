import {
  SQSClient,
} from "@aws-sdk/client-sqs";
import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";

const region = "ap-northeast-2";
const dynamodb = new DynamoDBClient({ region: region });
const sqs = new SQSClient({ region: region });

const tableName = process.env.TABLE_NAME

export const handler = async (event) => {
  
  try {
    console.info('-----------------------------------------------------------');
    console.log('event: ', event);
    console.info('-----------------------------------------------------------');
    const orderData = JSON.parse(event.Records[0].body);

    // Store the order data in DynamoDB
    await saveOrderData(orderData);

    return {
      statusCode: 200,
      body: "Order information message processed and stored in DynamoDB",
    };
  } catch (error) {
    console.error("Error processing order information message:", error);
    return {
      statusCode: 500,
      body: "Error processing order information message",
    };
  }
};

async function saveOrderData(orderData) {
  const params = {
    TableName: `${tableName}`,
    Item: {
      orderNo: { S: orderData.orderNo },
      customerName : { S: orderData.customerName },
      // Add other attributes as needed
      productName : { S: orderData.productName },
      originalPrice : { N: `${orderData.originalPrice}` },
      discountedPrice : { N: `${orderData.discountedPrice}` },
    },
  };
  console.log('params: ', params);

  const command = new PutItemCommand(params);
  await dynamodb.send(command);
}

