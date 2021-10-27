variable "intersight_apikey" {
  description = "Intersight API Key"
  type        = string
}

variable "intersight_secretkey" {
  description = "Intersight API Secret"
  type        = string
}

variable "intersight_endpoint" {
  description = "Intersight API endpoint"
  type        = string
  default     = "https://www.intersight.com"
}