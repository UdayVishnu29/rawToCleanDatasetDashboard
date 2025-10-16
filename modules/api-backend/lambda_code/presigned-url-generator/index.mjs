import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { randomUUID } from "crypto";

const s3Client = new S3Client({});
const BUCKET_NAME = process.env.UPLOAD_BUCKET_NAME;

export const handler = async (event) => {
  if (event.requestContext.http.method === "OPTIONS") {
    return {
      statusCode: 204,
      headers: {
        "Access-Control-Allow-Origin": "*", // Allow any origin
        "Access-Control-Allow-Headers": "Content-Type", // Allow the 'Content-Type' header
        "Access-Control-Allow-Methods": "POST, OPTIONS", // Allow POST and OPTIONS methods
      },
      body: "",
    };
  }

  // Your existing logic for the POST request
  try {
    const body = JSON.parse(event.body || "{}");
    const fileName = body.fileName;

    if (!fileName) {
      return {
        statusCode: 400,
        body: JSON.stringify({ message: "fileName is required" }),
      };
    }

    const sessionId = `session-${randomUUID()}`;
    const objectKey = `${sessionId}/${fileName}`;

    const command = new PutObjectCommand({
      Bucket: BUCKET_NAME,
      Key: objectKey,
    });

    const signedUrl = await getSignedUrl(s3Client, command, { expiresIn: 300 });

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
      },
      body: JSON.stringify({
        uploadUrl: signedUrl,
        sessionId: sessionId,
      }),
    };
  } catch (err) {
    console.error("Error generating pre-signed URL:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Internal server error" }),
    };
  }
};
