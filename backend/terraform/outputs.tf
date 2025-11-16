output "app_instance_public_ip" {
  description = "Public IP of the application EC2 instance"
  value       = aws_instance.app.public_ip
}

output "app_instance_private_ip" {
  description = "Private IP of the application EC2 instance"
  value       = aws_instance.app.private_ip
}

output "db_instance_public_ip" {
  description = "Public IP of the database EC2 instance"
  value       = aws_instance.db.public_ip
}

output "db_instance_private_ip" {
  description = "Private IP of the database EC2 instance"
  value       = aws_instance.db.private_ip
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for file storage"
  value       = aws_s3_bucket.wardrobe_storage.id
}

output "mongodb_connection_string" {
  description = "MongoDB connection string for application"
  value       = "mongodb://${aws_instance.db.private_ip}:27017/Digital_Wardrobe"
  sensitive   = false
}
