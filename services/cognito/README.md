# VClipper Cognito Authentication Service

This Terraform configuration provisions AWS Cognito User Pool for VClipper application authentication using API-driven authentication (no Hosted UI), optimized for React frontend integration.

## 🚀 Features

- **API-Driven Authentication**: Direct integration with Cognito APIs (no redirects)
- **React-Optimized**: Configured specifically for frontend SDK integration
- **JWT Token Management**: Secure token-based authentication with refresh capability
- **Email Verification**: Built-in email verification workflow
- **Educational Environment**: Simplified configuration for development and learning
- **No Hosted UI**: Clean API-only authentication flow

## 📐 Current Architecture

```
React Frontend → Cognito APIs (Direct) → JWT Tokens → API Gateway (JWT Validation) → Backend Services
```

## 🛠️ Project Structure

```
.
├── cognito.tf              # Cognito User Pool and Client configuration
├── variables.tf            # Input variable definitions
├── outputs.tf              # Output value definitions
├── backend.tf              # Terraform backend and provider configuration
├── terraform.tfvars        # Variable values (gitignored)
└── README.md               # This documentation
```

## 🛠️ Terraform Resources

| Resource Type | Purpose |
|---------------|---------|
| `aws_cognito_user_pool` | Creates the user pool for authentication |
| `aws_cognito_user_pool_client` | Configures app client for API access |

## 🚀 Deployment

### Prerequisites
1. **AWS CLI Configured** with valid credentials
2. **Terraform v1.12+** installed
3. **Global Terraform State** deployed (for project name and region)

### Configuration Variables
- `environment`: Environment name (default: "dev")
- `user_pool_name`: User pool name (default: "vclipper-users")
- `app_client_name`: App client name (default: "vclipper-web-client")
- `mfa_configuration`: MFA setting (default: "OFF")

## 🛠️ How to Run Terraform

### One-time Initialization (Required for new developers)
Before running plan/apply for the first time, initialize the backend:
```bash
terraform init
```

### Regular Operations
After initialization, you can run normal Terraform commands:
```bash
# Preview changes
terraform plan

# Apply changes
terraform apply

# Destroy resources (if needed)
terraform destroy
```

## 🔧 Current Configuration

After deployment, your Cognito service provides:

- **User Pool ID**: `us-east-1_SUMiE0yRW`
- **Client ID**: `3r2uf0r673ronu2bgdsljbjamd`
- **Region**: `us-east-1`
- **JWT Issuer**: `https://cognito-idp.us-east-1.amazonaws.com/us-east-1_SUMiE0yRW`

## 🔒 Security Configuration

### ✅ **Authentication Features:**
- **Password Policy**: 8+ characters, uppercase, lowercase, numbers required
- **Password History**: Prevents reuse of last 4 passwords for enhanced security
- **Email Verification**: Required for account activation
- **Advanced Security Mode**: ENFORCED - Provides risk-based authentication and adaptive authentication
- **Account Protection**: Automatic detection and blocking of suspicious sign-in attempts
- **JWT Tokens**: 1-hour access/ID tokens, 30-day refresh tokens
- **SRP Authentication**: Secure Remote Password protocol

### 🔒 **Advanced Security Features (ENFORCED):**
- **Risk-Based Authentication**: Analyzes sign-in patterns and device fingerprints
- **Adaptive Authentication**: Challenges users based on risk assessment
- **Compromised Credentials Detection**: Blocks known compromised passwords
- **Suspicious Activity Monitoring**: Tracks and responds to unusual login patterns
- **Device Tracking**: Remembers trusted devices to reduce friction

### 🔒 **Password Security:**
- **Complex Requirements**: Minimum 8 characters with mixed case, numbers
- **History Enforcement**: Cannot reuse last 4 passwords
- **Compromised Password Protection**: AWS maintains database of known compromised passwords

### 🔒 **Simplified for Education:**
- **MFA Disabled**: No SMS costs or complexity (can be enabled if needed)
- **No Hosted UI**: Direct API integration only
- **LabRole Compatible**: Works with educational AWS constraints

## 🚀 React Application Integration

### Environment Variables
Add these to your React app's `.env` file:
```bash
REACT_APP_AWS_REGION=us-east-1
REACT_APP_COGNITO_USER_POOL_ID=us-east-1_SUMiE0yRW
REACT_APP_COGNITO_USER_POOL_CLIENT_ID=3r2uf0r673ronu2bgdsljbjamd
```

### Installation
```bash
# Install Cognito SDK
npm install amazon-cognito-identity-js
```

### Basic Implementation
```javascript
import { CognitoUserPool, CognitoUser, AuthenticationDetails } from 'amazon-cognito-identity-js';

// Configuration
const poolData = {
  UserPoolId: process.env.REACT_APP_COGNITO_USER_POOL_ID,
  ClientId: process.env.REACT_APP_COGNITO_USER_POOL_CLIENT_ID
};

const userPool = new CognitoUserPool(poolData);

// Sign Up Function
const signUp = (email, password, name) => {
  return new Promise((resolve, reject) => {
    userPool.signUp(email, password, [
      { Name: 'email', Value: email },
      { Name: 'name', Value: name }
    ], null, (err, result) => {
      if (err) reject(err);
      else resolve(result);
    });
  });
};

// Sign In Function
const signIn = (email, password) => {
  const authenticationDetails = new AuthenticationDetails({
    Username: email,
    Password: password
  });
  
  const cognitoUser = new CognitoUser({
    Username: email,
    Pool: userPool
  });
  
  return new Promise((resolve, reject) => {
    cognitoUser.authenticateUser(authenticationDetails, {
      onSuccess: resolve,
      onFailure: reject
    });
  });
};

// Email Verification
const confirmSignUp = (email, code) => {
  const cognitoUser = new CognitoUser({
    Username: email,
    Pool: userPool
  });
  
  return new Promise((resolve, reject) => {
    cognitoUser.confirmRegistration(code, true, (err, result) => {
      if (err) reject(err);
      else resolve(result);
    });
  });
};
```

## 🔄 Authentication Flow

### 1. **User Registration**
```javascript
// User fills signup form in React app
const handleSignUp = async (email, password, name) => {
  try {
    const result = await signUp(email, password, name);
    // Show verification code input
    setStep('verify-email');
  } catch (error) {
    // Handle signup error
  }
};
```

### 2. **Email Verification**
```javascript
// User enters verification code
const handleVerification = async (email, code) => {
  try {
    await confirmSignUp(email, code);
    // Account verified, proceed to login
    setStep('login');
  } catch (error) {
    // Handle verification error
  }
};
```

### 3. **User Login**
```javascript
// User fills login form
const handleLogin = async (email, password) => {
  try {
    const result = await signIn(email, password);
    // Get JWT tokens
    const accessToken = result.getAccessToken().getJwtToken();
    const idToken = result.getIdToken().getJwtToken();
    
    // Store tokens and update app state
    localStorage.setItem('accessToken', accessToken);
    setUser(result);
    navigate('/dashboard');
  } catch (error) {
    // Handle login error
  }
};
```

### 4. **API Calls with JWT**
```javascript
// Include JWT in API requests
const makeAuthenticatedRequest = async (url, options = {}) => {
  const token = localStorage.getItem('accessToken');
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${token}`
    }
  });
};
```

## 🔄 API Gateway Integration

### JWT Configuration for API Gateway
```json
{
  "issuer": "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_SUMiE0yRW",
  "audience": "3r2uf0r673ronu2bgdsljbjamd"
}
```

### API Gateway Authorizer Setup
```hcl
resource "aws_api_gateway_authorizer" "cognito" {
  name                   = "cognito-authorizer"
  rest_api_id           = aws_api_gateway_rest_api.main.id
  type                  = "COGNITO_USER_POOLS"
  provider_arns         = [data.terraform_remote_state.cognito.outputs.user_pool_arn]
  identity_source       = "method.request.header.Authorization"
}
```

## 📊 Outputs

Key outputs for integration with other services:

| Output | Description | Usage |
|--------|-------------|-------|
| `user_pool_id` | Cognito User Pool ID | Frontend configuration |
| `user_pool_client_id` | App Client ID | Frontend configuration |
| `user_pool_arn` | User Pool ARN | API Gateway authorizers |
| `cognito_config` | Complete configuration | Service integration |
| `frontend_env_vars` | React environment variables | Frontend deployment |
| `jwt_configuration` | JWT settings | API Gateway setup |

## 🔧 Troubleshooting

### Common Issues:

#### 1. **Authentication Fails**
```bash
# Check user pool configuration
aws cognito-idp describe-user-pool --user-pool-id us-east-1_SUMiE0yRW

# Verify user exists and is confirmed
aws cognito-idp list-users --user-pool-id us-east-1_SUMiE0yRW
```

#### 2. **Email Verification Issues**
- Check spam folder for verification emails
- Verify email attribute is required in user pool
- Ensure email is not already confirmed

#### 3. **JWT Token Issues**
- Check token expiration (1 hour for access tokens)
- Verify issuer and audience in API Gateway
- Ensure proper Authorization header format

### Useful Commands:

```bash
# List user pools
aws cognito-idp list-user-pools --max-results 10

# Create test user (for development)
aws cognito-idp admin-create-user \
  --user-pool-id us-east-1_SUMiE0yRW \
  --username testuser@example.com \
  --user-attributes Name=email,Value=testuser@example.com Name=name,Value="Test User" \
  --temporary-password TempPass123! \
  --message-action SUPPRESS

# Test authentication
aws cognito-idp admin-initiate-auth \
  --user-pool-id us-east-1_SUMiE0yRW \
  --client-id 3r2uf0r673ronu2bgdsljbjamd \
  --auth-flow ADMIN_NO_SRP_AUTH \
  --auth-parameters USERNAME=testuser@example.com,PASSWORD=TempPass123!

# Reset user password
aws cognito-idp admin-set-user-password \
  --user-pool-id us-east-1_SUMiE0yRW \
  --username testuser@example.com \
  --password NewPassword123! \
  --permanent
```

## 💰 Cost Considerations

- **User Pool**: Free tier covers up to 50,000 MAUs (Monthly Active Users)
- **Advanced Security**: Additional cost for risk-based authentication
- **No Hosted UI**: No CloudFront distribution costs
- **No SMS**: No MFA SMS costs (MFA disabled)
- **JWT Tokens**: No additional cost for token generation/validation

## 📈 Monitoring

Monitor authentication through:
- **CloudWatch Logs**: Cognito service logs
- **CloudWatch Metrics**: Authentication success/failure rates  
- **AWS Console**: User pool analytics and user management
- **Application Logs**: Frontend authentication events

## 🚀 Next Steps

After deploying Cognito:
1. **Deploy API Gateway** service with JWT authorizer
2. **Update Frontend** environment variables
3. **Implement Authentication** in React app
4. **Test Signup/Signin** flow end-to-end
5. **Deploy Backend Services** with API Gateway integration
