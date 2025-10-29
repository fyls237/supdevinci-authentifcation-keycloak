# General variables
variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Secret variables
variable "secret_name_prefix" {
  description = "Prefix for the secret name (AWS will append random characters)"
  type        = string
}

variable "description" {
  description = "Description of the secret"
  type        = string
  default     = ""
}

variable "secret_string" {
  description = "Secret value as a string (use this for simple secrets)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "secret_json" {
  description = "Secret value as JSON (use this for complex secrets with key-value pairs)"
  type        = string
  default     = ""
  sensitive   = true
}

# Encryption
variable "kms_key_id" {
  description = "KMS key ID for encryption (leave empty to use default AWS managed key)"
  type        = string
  default     = null
}

# Recovery
variable "recovery_window_in_days" {
  description = "Number of days to recover deleted secret (0 to force delete immediately)"
  type        = number
  default     = 30
}

# Rotation
variable "enable_rotation" {
  description = "Enable automatic rotation of the secret"
  type        = bool
  default     = false
}

variable "rotation_lambda_arn" {
  description = "ARN of Lambda function for secret rotation (required if enable_rotation is true)"
  type        = string
  default     = ""
}

variable "rotation_days" {
  description = "Number of days between automatic rotations"
  type        = number
  default     = 30
}

# Policy
variable "secret_policy" {
  description = "JSON resource policy for the secret (leave empty for no policy)"
  type        = string
  default     = ""
}
