# AWS IoT Device Functions Simulation

> :warning: **Disclaimer**: For Chainlink Functions demo purposes only. Do not use in production!

This repo combines Chainlink Price Feeds, Automation and Functions to simulate a real world alert being triggered by an on-chain blackswan event (i.e. stablecoin depeg). A Patlite Network Monitor IoT device can be triggered via the [functions-toolkit](https://github.com/smartcontractkit/functions-toolkit).

<img src="https://i.imgur.com/PmO2Gvt.jpg" alt="Architecture Diagram" width="600">

## Set up your environment

1.  [Install Deno](https://deno.land/manual/getting_started/installation) so you can compile and simulate your Functions source code.

2.  - [Install Node.js](https://nodejs.org/en/download/). If you have issue, you may need to use the [nvm package](https://www.npmjs.com/package/nvm) to switch between Node.js versions to specify `nvm use 18`.

3.  In a terminal, clone this repoand change directories.

        git clone https://github.com/smartcontractkit/functions-aws-iot-core.git && \
        cd functions-aws-iot-core/

4.  Run `npm install` to install the dependencies.
    npm install

5.  Configure your IoT device, in this example we use a Patlite [NHL-FV2](https://www.patlite.com/catalogimg/EN_KF_021465_EUJfQqhY.pdf)

# Run Simulation

1.  Run a simulated alert for Patlite NHL-FV2 on local network:

        node ./example/request.js

    (Hit the "clear" button on the IoT Device to stop the alert)

# Network Deployments

## Publish MQTT Message on AWS IoT Core Using HTTP API

> :warning: **Note**: As of 08/25/23 the Chainlink Functions beta does not support external libraries. Once available, the process outlined below is an example approach. Alternatively, you can also try deploying [AWS SigV4 Proxy](https://github.com/awslabs/aws-sigv4-proxy) + [AWS IoT Core HTTPS](https://docs.aws.amazon.com/iot/latest/developerguide/http.html) as a workaround.

To publish an MQTT message on AWS IoT Core using the HTTP API, you can follow these steps:

1. **Set Up AWS IoT Core:**

   - Create an AWS IoT Core service on the AWS Management Console if you haven't already.
   - Create an IoT Thing and download the certificates and keys for the Thing.

2. **Generate an AWS Signature:**

   - To make authenticated requests to the AWS IoT Core API, you need to generate an AWS signature. You can use the `aws4` library in Node.js to generate the signature. Install it using npm:

     ```bash
     npm install aws4
     ```

   - This code snippet demonstrates how to use the AWS IoT Core REST API to publish an MQTT message via HTTP. It signs the request with your AWS credentials and sends the message to the specified MQTT topic. It is highly recommended to use secrets to store credentials:

     ```javascript
     // THIS IS EXAMPLE CODE THAT USES HARDCODED VALUES FOR CLARITY.
     // DO NOT USE THIS CODE IN PRODUCTION.

     const aws4 = require("aws4");
     const AWS = require("aws-sdk");

     // Configure AWS credentials
     AWS.config.update({
       accessKeyId: "YOUR_ACCESS_KEY_ID",
       secretAccessKey: "YOUR_SECRET_ACCESS_KEY",
       region: "YOUR_AWS_REGION",
     });

     // Define your IoT endpoint
     const iotEndpoint = "YOUR_IOT_ENDPOINT";

     // Define the MQTT topic and message to publish
     const topic = "YOUR_MQTT_TOPIC";
     const message = "Hello, AWS IoT!";

     // Generate AWS signature for the request
     const requestOptions = {
       host: iotEndpoint,
       method: "POST",
       path: `/topics/${topic}?qos=0`, // Set qos (quality of service) as needed
       service: "iotdata",
       region: AWS.config.region,
       body: message,
     };

     aws4.sign(requestOptions);

     // Send the HTTP request
     const https = require("https");
     const req = https.request(requestOptions, (res) => {
       console.log(`Status Code: ${res.statusCode}`);
       res.on("data", (data) => {
         console.log(`Response Data: ${data.toString()}`);
       });
     });

     req.on("error", (err) => {
       console.error(`Error: ${err.message}`);
     });

     // Send the message
     req.write(message);
     req.end();
     ```

   Replace the placeholders (`YOUR_...`) with the appropriate values from your AWS IoT setup.

3. **Integrate your JavaScript Code in Chainlink Functions:**
   - Update `source.js` JavaScript code with the above, which will publish the MQTT message to the specified topic via Chainlink Functions.
  
## Disclaimer

This tutorial offers educational examples of how to use a Chainlink system, product, or service and is provided to demonstrate how to interact with Chainlink’s systems, products, and services to integrate them into your own. This template is provided “AS IS” and “AS AVAILABLE” without warranties of any kind, it has not been audited, and it may be missing key checks or error handling to make the usage of the system, product, or service more clear. Do not use the code in this example in a production environment without completing your own audits and application of best practices. Neither Chainlink Labs, the Chainlink Foundation, nor Chainlink node operators are responsible for unintended outputs that are generated due to errors in code.
