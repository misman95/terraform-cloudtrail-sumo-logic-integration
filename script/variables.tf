variable "sumo_env_region" {
  description = "Sumo Logic Region (Default: Japan)"
  default     = "jp"
  type        = string
}

variable "sumo_env_accessid" {
  description = "Sumo Logic Access id"
  default     = "Provide your Sumo Logic Access ID here"
  type        = string
}

variable "sumo_env_accesskey" {
  description = "Sumo Logic Access key"
  default     = "Provide your Sumo Logic Access Key here"
  type        = string
}


variable "aws_profile" {
  description = "AWS Profile"
  default     = "default"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  default     = "us-west-1"
  type        = string
}

variable "s3_bucket" {
  description = "s3 bucket name for Cloudtrail"
  default     = "trail-sumologic"
  type        = string
}

variable "trail_name" {
  description = "Name for the Cloudtrail"
  default     = "trail-sumologic"
  type        = string
}

variable "role_identifiers" {
  description = "Sumo Logic Identifiers - get from Sumo Logic Console"
  default     = "Provide your Account ID here"
  type        = string
}

variable "role_condition" {
  description = "Sumo Logic Role Condition - get from Sumo Logic Console"
  default     = "Provide your External ID here"
  type        = string
}

variable "role_name" {
  description = "Sumo Logic Role Name"
  default     = "trail-sumo-role"
  type        = string
}


