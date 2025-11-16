provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_vpc" "default" {
  default = true
}

# Security group for application instance
resource "aws_security_group" "app_sg" {
  name        = "wardrobe-app-sg${var.resource_name_suffix}"
  description = "Security group for application instance"
  vpc_id      = data.aws_vpc.default.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App Port"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Nagios NRPE"
    from_port       = 5666
    to_port         = 5666
    protocol        = "tcp"
    security_groups = [aws_security_group.nagios_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "wardrobe-app-sg${var.resource_name_suffix}" }
}

# Security group for database instance
resource "aws_security_group" "db_sg" {
  name        = "wardrobe-db-sg${var.resource_name_suffix}"
  description = "Security group for MongoDB database instance"
  vpc_id      = data.aws_vpc.default.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MongoDB port - only allow from app instance
  ingress {
    description     = "MongoDB"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  ingress {
    description     = "Nagios NRPE"
    from_port       = 5666
    to_port         = 5666
    protocol        = "tcp"
    security_groups = [aws_security_group.nagios_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "wardrobe-db-sg${var.resource_name_suffix}" }
}

# Security group for Nagios monitoring server
resource "aws_security_group" "nagios_sg" {
  name        = "wardrobe-nagios-sg${var.resource_name_suffix}"
  description = "Security group for Nagios monitoring server"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Nagios Web Interface"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Nagios Web Interface HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "wardrobe-nagios-sg${var.resource_name_suffix}" }

  lifecycle {
    create_before_destroy = true
  }
}

# Application instance
resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.app_profile.name

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y python3 python3-pip ansible git curl
              EOF

  tags = {
    Name        = "DigitalWardrobe-App"
    Environment = "Production"
    Role        = "Application"
  }
}

# Database instance (MongoDB)
resource "aws_instance" "db" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.db_instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.db_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y python3 python3-pip ansible git curl
              EOF

  tags = {
    Name        = "DigitalWardrobe-DB"
    Environment = "Production"
    Role        = "Database"
  }
}

# Nagios monitoring server
resource "aws_instance" "nagios" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.nagios_instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.nagios_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y python3 python3-pip ansible git curl
              EOF

  tags = {
    Name        = "DigitalWardrobe-Nagios"
    Environment = "Production"
    Role        = "Monitoring"
  }
}

# Random ID for bucket suffix
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 bucket for file storage
resource "aws_s3_bucket" "wardrobe_storage" {
  bucket = "${var.bucket_name_prefix}-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "Digital Wardrobe Storage"
    Environment = "Production"
  }
}

# Disable Block Public Access for this bucket
resource "aws_s3_bucket_public_access_block" "wardrobe_storage_public_access" {
  bucket = aws_s3_bucket.wardrobe_storage.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

# Allow public read access to uploads folder only
resource "aws_s3_bucket_policy" "wardrobe_storage_policy" {
  bucket = aws_s3_bucket.wardrobe_storage.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.wardrobe_storage.arn}/uploads/*"
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.wardrobe_storage_public_access
  ]
}

# Enable versioning
resource "aws_s3_bucket_versioning" "wardrobe_storage" {
  bucket = aws_s3_bucket.wardrobe_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# IAM role for app instance to access S3
resource "aws_iam_role" "app_role" {
  name = "wardrobe-app-role${var.resource_name_suffix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "wardrobe-app-role${var.resource_name_suffix}"
  }
}

# IAM policy to allow S3 access
resource "aws_iam_role_policy" "app_s3_policy" {
  name = "wardrobe-app-s3-policy${var.resource_name_suffix}"
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.wardrobe_storage.arn,
          "${aws_s3_bucket.wardrobe_storage.arn}/*"
        ]
      }
    ]
  })
}

# Instance profile for the app instance
resource "aws_iam_instance_profile" "app_profile" {
  name = "wardrobe-app-profile${var.resource_name_suffix}"
  role = aws_iam_role.app_role.name
}

