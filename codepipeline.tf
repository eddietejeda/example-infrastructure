################################################################################
# CodePipeline
################################################################################

# Pipeline resource for building docker image and pushing to ECR
resource "aws_codestarconnections_connection" "github_connection" {
  name          = "github-connection"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "deploy_pipeline" {
  name     = "${var.name}-codepipeline"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.bucket.id}"
    type     = "S3"

    encryption_key {
      id   = "${data.aws_kms_alias.s3kmskey.arn}"
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      owner     = "AWS"
      provider  = "CodeStarSourceConnection"
      name      = "Source"
      category  = "Source"
      output_artifacts = ["SourceCode"]
      version = 1

      configuration = {
        ConnectionArn      = aws_codestarconnections_connection.github_connection.arn
        FullRepositoryId   = "${var.github_url}"
        BranchName         = "main"
      }

    }
  }

  stage {
    name = "BuildImage"
    action {
      owner     = "AWS"
      provider  = "CodeBuild"
      name      = "BuildImage"
      category  = "Build"

      input_artifacts = ["SourceCode"]
      run_order = 3
      version = 1

      configuration = {
        ProjectName = "${aws_codebuild_project.codebuild_project.name}"
      }

      output_artifacts = ["DockerImage"]

    }
  }
}


# Webhook 

resource "aws_codepipeline_webhook" "webhook" {
  name            = "${var.name}_TERRAFORM"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = "${aws_codepipeline.deploy_pipeline.name}"

  authentication_configuration {
    secret_token = "${aws_ssm_parameter.github_webhook_secret.value}"
  }
  
  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}


# Codepipeline IAM data
data "aws_iam_policy_document" "codepipeline_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codepipeline_policy" {
  # TODO: Minimize permissions
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
      "ecr:BatchGetImage"
    ]

    resources = [
      "${aws_ecr_repository.repository.arn}*",
    ]
  }
  statement {
    actions = [
      "s3:*",
    ]
    resources = [
      "${aws_s3_bucket.bucket.arn}*",
    ]
  }
  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
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
      "*"
    ]
    resources = [
      "*"
    ]
  }
}



# IAM resources
resource "aws_iam_role" "codepipeline_role" {
  name    = "${var.name}-codepipeline"  
  assume_role_policy = "${data.aws_iam_policy_document.codepipeline_assume_role_policy.json}"
  tags = local.tags
}

resource "aws_iam_role_policy" "codepipeline_role_policy" {
  name    = "${var.name}-codepipeline"  
  role    = "${aws_iam_role.codepipeline_role.name}"
  policy  = "${data.aws_iam_policy_document.codepipeline_policy.json}"
}
