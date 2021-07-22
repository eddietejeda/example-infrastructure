resource "aws_ecr_repository" "repository" {
  name = "${local.name}"
  tags = local.tags
}

resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  repository = "${aws_ecr_repository.repository.name}"

  policy = <<EOF
{
  "rules": [{
    "rulePriority": 1,
    "description": "Expire images older than 14 days",
    "selection": {
      "tagStatus": "untagged",
      "countType": "sinceImagePushed",
      "countUnit": "days",
      "countNumber": 14
    },
    "action": {
        "type": "expire"
    }
  }]
}
EOF
}
