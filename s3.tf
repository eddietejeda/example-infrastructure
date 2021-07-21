################################################################################
# S3
################################################################################
resource "aws_s3_bucket" "bucket" {
  bucket          = "${local.bucket_name}"
  acl             = "private"
  force_destroy   = true
  tags            = local.tags
}

# Rename to secrets
resource "aws_s3_bucket_object" "object" {
  bucket          = aws_s3_bucket.bucket.id
  key             =  "dev.env"
  source          = "secrets/dev.env"
  etag            = filemd5("secrets/dev.env")
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode({
   "Version":"2012-10-17",
   "Statement":[
      {
        "Effect":"Allow",
        "Action":[
          "s3:*",
        ],
        "Resource": [
          "${aws_s3_bucket.bucket.arn}",
          "${aws_s3_bucket.bucket.arn}/*"
        ],
        "Principal": {
          "AWS": "${aws_iam_role.iam_role.arn}"
        }
      }
   ]
  })
}

