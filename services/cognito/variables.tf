variable "terraform_state_bucket" {
  description = "Name of the S3 bucket storing Terraform state"
  type        = string
  default     = "vclipper-terraform-state-dev-rmxhnjty"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
  default     = "vclipper-users"
}

variable "identity_pool_name" {
  description = "Name of the Cognito Identity Pool"
  type        = string
  default     = "vclipper-identity"
}

variable "app_client_name" {
  description = "Name of the Cognito App Client"
  type        = string
  default     = "vclipper-web-client"
}

variable "password_policy" {
  description = "Password policy configuration"
  type = object({
    minimum_length        = number
    require_lowercase     = bool
    require_numbers       = bool
    require_symbols       = bool
    require_uppercase     = bool
    password_history_size = number
  })
  default = {
    minimum_length        = 8
    require_lowercase     = true
    require_numbers       = true
    require_symbols       = false
    require_uppercase     = true
    password_history_size = 4
  }
}

variable "auto_verified_attributes" {
  description = "Attributes to be auto-verified"
  type        = list(string)
  default     = ["email"]
}

variable "mfa_configuration" {
  description = "Multi-factor authentication configuration"
  type        = string
  default     = "OFF"
  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "MFA configuration must be OFF, ON, or OPTIONAL."
  }
}

variable "account_recovery_setting" {
  description = "Account recovery setting"
  type = object({
    recovery_mechanisms = list(object({
      name     = string
      priority = number
    }))
  })
  default = {
    recovery_mechanisms = [
      {
        name     = "verified_email"
        priority = 1
      }
    ]
  }
}

variable "existing_role_name" {
  description = "Name of existing IAM role to use for backend services (found: LabRole)"
  type        = string
  default     = "LabRole"
}
