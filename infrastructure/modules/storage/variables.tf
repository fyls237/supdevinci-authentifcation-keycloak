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

# S3 Bucket variables
variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name (AWS will append random characters)"
  type        = string
}

variable "force_destroy" {
  description = "Allow bucket to be destroyed even if it contains objects"
  type        = bool
  default     = false
}

# Versioning
variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

# Encryption
variable "sse_algorithm" {
  description = "Server-side encryption algorithm (AES256 or aws:kms)"
  type        = string
  default     = "AES256"
}

variable "kms_master_key_id" {
  description = "KMS key ID for encryption (required if sse_algorithm is aws:kms)"
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Enable S3 Bucket Key for encryption"
  type        = bool
  default     = true
}

# Public Access Block
variable "block_public_acls" {
  description = "Block public ACLs"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public bucket policies"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public bucket policies"
  type        = bool
  default     = true
}

# Logging
variable "logging_bucket_name" {
  description = "Name of the bucket to store access logs (leave empty to disable logging)"
  type        = string
  default     = ""
}

variable "logging_prefix" {
  description = "Prefix for log objects"
  type        = string
  default     = "logs/"
}

# Lifecycle Rules
variable "enable_lifecycle_rules" {
  description = "Enable lifecycle rules for the bucket"
  type        = bool
  default     = false
}

variable "transition_to_ia_days" {
  description = "Number of days before transitioning to STANDARD_IA"
  type        = number
  default     = 30
}

variable "transition_to_glacier_days" {
  description = "Number of days before transitioning to GLACIER"
  type        = number
  default     = 90
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days before deleting noncurrent versions"
  type        = number
  default     = 90
}

# Bucket Policy
variable "bucket_policy" {
  description = "JSON bucket policy (leave empty for no policy)"
  type        = string
  default     = ""
}
