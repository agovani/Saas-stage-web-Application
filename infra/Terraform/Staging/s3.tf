resource "aws_s3_bucket" "app_files" {
  bucket = "${var.project}-files"

  tags = {
    Name        = "${var.project}-files"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.app_files.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.app_files.arn}",
          "${aws_s3_bucket.app_files.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
