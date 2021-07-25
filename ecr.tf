resource "aws_ecr_repository" "repository" {
  name = "${local.name}"
  tags = local.tags
}

data "aws_ecr_image" "image" {
  repository_name = "linkbird"
  image_tag       = "latest"
}

resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  repository = "${aws_ecr_repository.repository.name}"

  policy = <<EOF
{
  "rules": [{
    "rulePriority": 1,
    "description": "Expire images after 5 releases",
    "selection": {
      "tagStatus": "untagged",
      "countType": "imageCountMoreThan",
      "countNumber": 5
    },
    "action": {
        "type": "expire"
    }
  }]
}
EOF
}