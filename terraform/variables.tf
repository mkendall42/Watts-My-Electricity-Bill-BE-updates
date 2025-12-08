variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"         #This is a (semi-)physical datacenter in VA (I assume this should be constant)
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "watts-my-electricity-bill-be"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}
