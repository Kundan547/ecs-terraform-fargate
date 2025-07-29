# modules/s3/variables.tf
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = true
}

variable "block_public_access" {
  description = "Block public access to the bucket"
  type        = bool
  default     = true
}

variable "enable_lifecycle" {
  description = "Enable lifecycle configuration"
  type        = bool
  default     = false
}

variable "expiration_days" {
  description = "Number of days after which objects expire"
  type        = number
  default     = 365
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days after which noncurrent versions expire"
  type        = number
  default     = 90
}

variable "transitions" {
  description = "List of lifecycle transitions"
  type = list(object({
    days          = number
    storage_class = string
  }))
  default = [
    {
      days          = 30
      storage_class = "STANDARD_IA"
    },
    {
      days          = 90
      storage_class = "GLACIER"
    }
  ]
}

variable "allowed_principals" {
  description = "List of AWS principals allowed to access the bucket"
  type        = list(string)
  default     = []
}

variable "allowed_actions" {
  description = "List of allowed actions for the bucket policy"
  type        = list(string)
  default = [
    "s3:GetObject",
    "s3:PutObject",
    "s3:DeleteObject",
    "s3:ListBucket"
  ]
}

