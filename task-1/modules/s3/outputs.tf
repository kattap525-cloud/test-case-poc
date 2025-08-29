output "product_images_bucket_name" {
  description = "Product images bucket name"
  value       = aws_s3_bucket.product_images.bucket
}

output "user_uploads_bucket_name" {
  description = "User uploads bucket name"
  value       = aws_s3_bucket.user_uploads.bucket
}

output "static_assets_bucket_name" {
  description = "Static assets bucket name"
  value       = aws_s3_bucket.static_assets.bucket
}
