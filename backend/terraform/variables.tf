variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "AWS EC2 keypair name"
  default     = "devops"
}

variable "app_port" {
  type    = number
  default = 3000
}

variable "db_instance_type" {
  type    = string
  default = "t3.micro"
  description = "Instance type for database server"
}

variable "bucket_name_prefix" {
  type    = string
  default = "digital-wardrobe-storage"
  description = "Prefix for S3 bucket name"
}