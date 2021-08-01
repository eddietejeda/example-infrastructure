################################################################################
# S3
################################################################################

# Bucket
resource "aws_s3_bucket" "bucket" {
  bucket          = "${var.bucket_name}"
  acl             = "private"
  force_destroy   = true
  tags            = local.tags
}

resource "aws_s3_bucket_object" "env" {
  bucket          = aws_s3_bucket.bucket.id
  key             =  "${var.environment}.env"
  source          = "env/${var.environment}.env"
  etag            = filemd5("env/${var.environment}.env")
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
          "AWS": [ 
            "${aws_iam_role.s3_role.arn}",
            "${aws_iam_role.ecs_role.arn}"
          ]
        }
      }
   ]
  })
}

# IAM 
resource "aws_iam_role" "s3_role" {
  name    = "${var.name}-s3-role"
  path    = "/"
  tags    = local.tags

  assume_role_policy = data.aws_iam_policy_document.s3_instance_assume_role_policy.json
}

resource "aws_iam_instance_profile" "s3_instance" {
  name       = "${var.name}-s3-instance"
  role       = aws_iam_role.s3_role.name
}

data "aws_iam_policy_document" "s3_instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}