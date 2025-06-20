# S3 bucket for Terraform state and artifacts
resource "aws_s3_bucket" "terraform_artifacts" {
  bucket = "${var.project_name}-terraform-artifacts"
}

resource "aws_s3_bucket_versioning" "terraform_artifacts" {
  bucket = aws_s3_bucket.terraform_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

# IAM role for CodePipeline
resource "aws_iam_role" "terraform_pipeline_role" {
  name = "${var.project_name}-terraform-pipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codepipeline.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM policy for CodePipeline
resource "aws_iam_role_policy" "terraform_pipeline_policy" {
  name = "${var.project_name}-terraform-pipeline-policy"
  role = aws_iam_role.terraform_pipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject"
        ],
        Resource = [
          aws_s3_bucket.terraform_artifacts.arn,
          "${aws_s3_bucket.terraform_artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ],
        Resource = "*"
      }
    ]
  })
}

# IAM role for CodeBuild
resource "aws_iam_role" "terraform_build_role" {
  name = "${var.project_name}-terraform-build-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codebuild.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM policy for CodeBuild with Terraform permissions
resource "aws_iam_role_policy" "terraform_build_policy" {
  name = "${var.project_name}-terraform-build-policy"
  role = aws_iam_role.terraform_build_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ],
        Resource = [
          aws_s3_bucket.terraform_artifacts.arn,
          "${aws_s3_bucket.terraform_artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:usdev*",
          "ecs:usdev*",
          "ecr:usdev*",
          "elasticloadbalancing:usdev*",
          "iam:usdev*",
          "logs:usdev*",
         
          "s3:usdev*",
          "sns:usdev*",
          
          "cloudwatch:usdev*",
          "codebuild:usdev*",
          "codepipeline:usdev*"
        ],
        Resource = "*"
      }
    ]
  })
}

# CodeBuild project for Terraform
resource "aws_codebuild_project" "terraform_build" {
  name          = "${var.project_name}-terraform-build"
  description   = "CodeBuild project for Terraform infrastructure"
  service_role  = aws_iam_role.terraform_build_role.arn
  build_timeout = 60

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_IN_AUTOMATION"
      value = "true"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.terraform_buildspec_path
  }
}

# CodePipeline for Terraform
resource "aws_codepipeline" "terraform_pipeline" {
  name     = "${var.project_name}-terraform-pipeline"
  role_arn = aws_iam_role.terraform_pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.terraform_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.terraform_codestar_connection_arn
        FullRepositoryId = var.terraform_repository_id
        BranchName       = var.terraform_branch_name
      }
    }
  }

  stage {
    name = "Plan"

    action {
      name             = "TerraformPlan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["plan_output"]

      configuration = {
        ProjectName = aws_codebuild_project.terraform_build.name
        EnvironmentVariables = jsonencode([
          {
            name  = "TF_COMMAND"
            value = "plan"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }

  stage {
    name = "Approve"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }

  stage {
    name = "Apply"

    action {
      name             = "TerraformApply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["apply_output"]

      configuration = {
        ProjectName = aws_codebuild_project.terraform_build.name
        EnvironmentVariables = jsonencode([
          {
            name  = "TF_COMMAND"
            value = "apply"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }
}
