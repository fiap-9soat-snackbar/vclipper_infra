# vclipper-lambda

# Lambda JWT Authorizer

This repository provides an AWS Lambda function to authenticate JWT tokens before granting access to protected API Gateway routes. The function is provisioned using Terraform, utilizes a Lambda Layer for Python dependencies (`PyJWT`).
## 🚀 Features

- **JWT Authentication:** Securely validates JWT tokens.
- **Terraform Provisioning:** Infrastructure as Code for reliable deployments.
- **Lambda Layer:** Efficiently manages external Python dependencies (`PyJWT`).
- **Pipeline Integration:** Resources automatically created by Terraform.
## 📐 Architecture

All incoming requests pass through AWS API Gateway, invoking the Lambda Authorizer:

- **API Gateway:** Receives requests and triggers the Lambda Authorizer.
- **Lambda Authorizer:** Authenticates JWT tokens from the `Authorization` header using the PyJWT library:
  - Validates JWT token signature with a secret key.
  - Verifies token expiration.
- **Lambda Layer:** Provides Python dependencies (`PyJWT`), isolating them from the main Lambda function.
## 🧩 Why Use a Lambda Layer?

Using Lambda Layers provides several advantages:

- **Reduced Deployment Size:** Keeps Lambda functions lightweight.
- **Easy Dependency Updates:** Update dependencies without redeploying the entire function.
- **Reusability:** Share dependencies across multiple Lambda functions, ensuring consistency.

In this project, a Lambda Layer is specifically used for managing the `PyJWT` library.
## 📝 Lambda Authorizer (Python - PyJWT)

This is the Python code used to validate JWT tokens:

```python
import json
import jwt  # PyJWT

JWT_SECRET = "3cfa76ef14937c1c0ea519f8fc057a80fcd04a7420f8e8bcd0a7567c272e007b"
JWT_ALGORITHM = "HS256"

def lambda_handler(event, context):
    """
    Lambda Authorizer for HTTP API (payload format 2.0).
    Returns:
      {
        "isAuthorized": True/False
      }
    """
    try:
        headers = event.get("headers", {})
        auth_header = headers.get("authorization", "")

        if not auth_header.startswith("Bearer "):
            return {"isAuthorized": False}

        token = auth_header.split(" ", 1)[1]

        try:
            jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
            return {"isAuthorized": True}
        except jwt.InvalidTokenError:
            print("Invalid or expired token.")
            return {"isAuthorized": False}

    except Exception as e:
        print("Unexpected error:", e)
        return {"isAuthorized": False}

```


---


## 🔄 API Gateway Integration Flow

The integration workflow between API Gateway and Lambda Authorizer:

1. API Gateway receives a request to a protected route.
2. API Gateway invokes the Lambda Authorizer, passing the JWT token.
3. Lambda Authorizer validates:
   - JWT token signature against the secret key.
   - Token expiration.
4.Lambda returns a response to API Gateway on successful execution:

```json
{
  "isAuthorized": true
}
```
5. Lambda returns an error response to API Gateway when execution fails:

```json
{
  "isAuthorized": false
}
```

---

## 🛠️ Terraform Resources

Terraform provisions the following AWS resources:

- **Lambda Layer** (`aws_lambda_layer_version`)
- **Lambda Function** (`aws_lambda_function`)
- **Lambda Permissions** (`aws_lambda_permission`)

---

## 📦 Automated Build Script (`build.sh`)

The provided `build.sh` script automates the packaging of the Lambda Authorizer function and its dependencies for deployment to AWS:

- **Lambda Layer packaging:** Automatically installs and packages Python dependencies (`PyJWT`) into a ZIP file for deployment as an AWS Lambda Layer.
- **Lambda Function packaging:** Copies the Lambda Authorizer function (`authorizer.py`) and packages it into a separate ZIP file, ready for direct deployment to AWS Lambda.

This script ensures that deployments are consistent, repeatable, and simplified, reducing manual effort and minimizing deployment errors.

## 🧪 Testing Lambda Authorizer with HTTP API 2.0 Event Script

This guide provides instructions on how to test the Lambda Authorizer using a Python script that generates a JWT token, simulates an AWS API Gateway event payload (HTTP API v2 format), and provides a convenient cURL command for quick testing.


## ✅ Purpose of the Test Script

This Python script is intended to facilitate testing of the Lambda Authorizer by automating the following tasks:

- **JWT Token Generation:** Creates a valid JWT token based on a predefined secret key.
- **Event Simulation:** Generates a mock API Gateway event in HTTP API 2.0 format compatible with AWS Lambda Authorizer testing.
- **cURL Testing:** Provides a ready-to-run cURL command to verify the integration via the API Gateway endpoint.

## 📌 Python Test Script

Save the following Python script as `generate_test_event.py`:

```python
import jwt
import datetime
import json

JWT_SECRET = "3cfa76ef14937c1c0ea519f8fc057a80fcd04a7420f8e8bcd0a7567c272e007b"
JWT_ALGORITHM = "HS256"

# JWT token expiration (1 hour from now)
exp_time = datetime.datetime.utcnow() + datetime.timedelta(hours=1)

# JWT payload with example user identifier ('sub')
payload = {
    "sub": "01234567890",
    "iat": datetime.datetime.utcnow(),
    "exp": exp_time
}

# Generate JWT token
token = jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

# Simulated HTTP API v2 event payload
event_v2 = {
    "version": "2.0",
    "routeKey": "GET /api/pickup",
    "rawPath": "/api/pickup",
    "headers": {
        "authorization": f"Bearer {token}"
    },
    "requestContext": {
        "http": {
            "method": "GET",
            "path": "/api/pickup"
        }
    }
}

# cURL command for quick endpoint testing
curl_command = f"""curl -i \\
  -X GET \\
  -H "Authorization: Bearer {token}" \\
  "https://lw461qp2r5.execute-api.us-east-1.amazonaws.com/api/pickup"
"""

# Print JSON event
print("=== Scenario 1: JSON v2 Event (HTTP API) ===")
print(json.dumps(event_v2, indent=2))

# Print cURL command
print("\n=== Scenario 2: cURL Command ===")
print(curl_command)
print()
```


---

### 📌 **Testing via Terminal 

```markdown
# 🚩 Testing via Terminal (cURL)

Follow these steps to test your Lambda Authorizer via the command line using cURL:

## Steps:

1. Execute the Python script to generate a JWT token and cURL command:

```bash
python generate_test.py

```
2. From the script output, copy the generated cURL command, which should appear as follows:

```bash
curl -i \
  -X GET \
  -H "Authorization: Bearer <generated-token>" \
  "https://lw461qp2r5.execute-api.us-east-1.amazonaws.com/api/pickup"

```

## ✅ Verify the Results

After executing your test requests, verify the responses based on the HTTP status code received:

| HTTP Response                                 | Meaning                          |
|-----------------------------------------------|----------------------------------|
| **`200 OK`**                                  | ✅ Authorized (Valid JWT token)  |
| **`401 Unauthorized` or `403 Forbidden`**     | ❌ Unauthorized (Invalid JWT token) |

- **Authorized:** Indicates your JWT token was correctly validated, and the Lambda Authorizer allowed the request.
- **Unauthorized:** Indicates the JWT token failed validation, either due to an invalid signature or expired token, and the request was denied.

# Create a Test Event in AWS Lambda

Follow these steps to create and run a test event using your copied JSON payload in the AWS Lambda Console.

## 🛠️ Steps:

- Navigate to the [AWS Lambda Console](https://console.aws.amazon.com/lambda/).
- Select Lambda Authorizer function (lambda-authorizer).
- Click on the **Test** tab.
- Set Template API Gateway Authorizer
- Choose **Create new event**.
- Paste your copied JSON payload generated into the event editor.

``` json

{
    "version": "2.0",
    "routeKey": "GET /api/pickup",
    "rawPath": "/api/pickup",
    "headers": {
        "authorization": "Bearer {token}"
    },
    "requestContext": {
        "http": {
            "method": "GET",
            "path": "/api/pickup"
        }
    }
}


```

- Provide a descriptive name for the event (e.g., `jwt-authorizer-test-event`).
- Click **Save**.
- Click **Test** to execute your new event.

### ✅ Verify the Results

If the JWT token is valid and has not expired, the Lambda Authorizer will return:

```json
{
  "isAuthorized": true
}


