#--------------------------------------------------------------
# Cognito User Pool
#--------------------------------------------------------------

resource "aws_cognito_user_pool" "main" {
  name = "${var.user_pool_name}-${var.environment}"

  # Password policy
  password_policy {
    minimum_length        = var.password_policy.minimum_length
    require_lowercase     = var.password_policy.require_lowercase
    require_numbers       = var.password_policy.require_numbers
    require_symbols       = var.password_policy.require_symbols
    require_uppercase     = var.password_policy.require_uppercase
    password_history_size = var.password_policy.password_history_size
  }

  # Auto verified attributes
  auto_verified_attributes = var.auto_verified_attributes

  # MFA configuration
  mfa_configuration = var.mfa_configuration

  # Account recovery setting
  account_recovery_setting {
    dynamic "recovery_mechanism" {
      for_each = var.account_recovery_setting.recovery_mechanisms
      content {
        name     = recovery_mechanism.value.name
        priority = recovery_mechanism.value.priority
      }
    }
  }

  # User pool add-ons
  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  # Email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Username configuration
  username_configuration {
    case_sensitive = false
  }

  # Schema for user attributes
  schema {
    attribute_data_type = "String"
    name               = "email"
    required           = true
    mutable            = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    attribute_data_type = "String"
    name               = "name"
    required           = true
    mutable            = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  # Verification message template
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "VClipper - Verify your email"
    email_message        = "Welcome to VClipper! Your verification code is {####}"
  }

  tags = {
    Name = "${var.user_pool_name}-${var.environment}"
  }
}

#--------------------------------------------------------------
# Cognito User Pool Client
#--------------------------------------------------------------

resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.app_client_name}-${var.environment}"
  user_pool_id = aws_cognito_user_pool.main.id

  # Token validity
  access_token_validity  = 60    # 1 hour
  id_token_validity      = 60    # 1 hour
  refresh_token_validity = 30    # 30 days

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  # Prevent user existence errors
  prevent_user_existence_errors = "ENABLED"

  # Explicit auth flows for API-driven authentication
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]

  # Read and write attributes
  read_attributes  = ["email", "name", "email_verified"]
  write_attributes = ["email", "name"]
}


