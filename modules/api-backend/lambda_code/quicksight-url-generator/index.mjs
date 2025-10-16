import {
  QuickSightClient,
  GenerateEmbedUrlForRegisteredUserCommand,
} from "@aws-sdk/client-quicksight";

const quicksightClient = new QuickSightClient({ region: "us-east-1" });
const DASHBOARD_ID = process.env.DASHBOARD_ID;
const AWS_ACCOUNT_ID = process.env.AWS_ACCOUNT_ID;
const QUICKSIGHT_USER_ARN =
  "arn:aws:quicksight:us-east-1:593793066128:user/default/whitedemon2004@gmail.com";

export const handler = async (event) => {
  const command = new GenerateEmbedUrlForRegisteredUserCommand({
    AwsAccountId: AWS_ACCOUNT_ID,
    UserArn: QUICKSIGHT_USER_ARN,
    ExperienceConfiguration: {
      Dashboard: { InitialDashboardId: DASHBOARD_ID },
    },
    SessionLifetimeInMinutes: 15,
  });

  try {
    const response = await quicksightClient.send(command);
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ EmbedUrl: response.EmbedUrl }),
    };
  } catch (err) {
    console.error("Error generating embed URL:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Could not generate dashboard URL." }),
    };
  }
};
