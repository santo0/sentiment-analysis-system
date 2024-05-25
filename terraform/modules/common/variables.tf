variable "ccbda-system-config" {
  description = "The name of the S3 bucket for system configuration"
  type        = string
  default     = "ccbda-system-config-121"
}

variable "customer_1_bucket" {
  description = "The name of the S3 bucket for customer 1"
  type        = string
  default     = "ccbda-customer-1-bucket-121"
}

variable "customer_2_bucket" {
  description = "The name of the S3 bucket for customer 2"
  type        = string
  default     = "ccbda-customer-2-bucket-1" 
}