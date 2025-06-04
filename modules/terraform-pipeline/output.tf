output "pipeline_name" {
  description = "Name of the Terraform CodePipeline"
  value       = aws_codepipeline.terraform_pipeline.name
}

output "artifact_bucket" {
  description = "S3 bucket for Terraform pipeline artifacts"
  value       = aws_s3_bucket.terraform_artifacts.bucket
}

output "codebuild_project_name" {
  description = "Name of the Terraform CodeBuild project"
  value       = aws_codebuild_project.terraform_build.name
}
