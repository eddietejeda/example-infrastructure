################################################################################
# CodeBuild
################################################################################

#  Based on the work from:
#  https://github.com/halfdanrump/terraform-aws-codepipeline-dockerbuild

resource "aws_codebuild_project" "codebuild_project" {
  name            = "${var.name}-codebuild"
  description     = "Builds ${var.name} Docker image"
  service_role    = "${aws_iam_role.codebuild_role.arn}"
  encryption_key  = "${data.aws_kms_alias.s3kmskey.arn}"
  
  artifacts {
    type = "NO_ARTIFACTS"
  }
  
  cache {
    location = "${aws_s3_bucket.bucket.id}"
    type = "S3"
  }
  
  environment {
    type                        = "LINUX_CONTAINER"
    image                       = "aws/codebuild/standard:2.0"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    type                  = "GITHUB"
    location              = "${var.github_url}"
    git_clone_depth       = 1

    buildspec = <<BUILD_SPEC
version: 0.2

env:
  shell: bash
  parameter-store:
      DOCKERHUB_USERNAME: /${var.name}/dockerhub/username
      DOCKERHUB_ACCESS_TOKEN: /${var.name}/dockerhub/access_token
  
phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - $(aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION)

  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...          
      - docker login --username $DOCKERHUB_USERNAME --password $DOCKERHUB_ACCESS_TOKEN
      - docker build -t ${var.codebuild_image} .
      - docker tag ${var.codebuild_image} ${aws_ecr_repository.repository.repository_url}
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - docker push ${aws_ecr_repository.repository.repository_url}

BUILD_SPEC
  }  

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.bucket.id}/build-log"
    }
  }

  tags = local.tags
}




# IAM Roles / Policy
resource "aws_iam_role" "codebuild_role" {
  name                = "${var.name}-codebuild-role"
  assume_role_policy  = "${data.aws_iam_policy_document.codebuild_assume_role_policy.json}"
  tags                = local.tags
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name      = "${var.name}-codebuild-role-policy"
  role      = "${aws_iam_role.codebuild_role.name}"
  policy    = "${data.aws_iam_policy_document.codebuild_policy.json}"
}


data "aws_iam_policy_document" "codebuild_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    sid = "1"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ssm:DescribeParameters",
      "ssm:GetParameters"
    ]
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "logs:*",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "s3:*",
    ]
    resources = [
      "${aws_s3_bucket.bucket.arn}",
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}

# Cloudwatch
resource "aws_cloudwatch_log_group" "codebuild" {
  name          = "${var.name}-codebuild-log"
  tags          = local.tags
}