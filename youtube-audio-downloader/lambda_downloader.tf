data "aws_ecr_repository" "yt_dlp_downloader" {
  name = "yt-dlp-downloader"
}

locals {
  app_version = file("app_version.txt")
}

resource "aws_lambda_function" "yt_dlp_downloader" {
  function_name    = "yt-dlp-downloader"
  timeout          = 300 # seconds
  image_uri        = "${data.aws_ecr_repository.yt_dlp_downloader.repository_url}:${local.app_version}"
  architectures    = ["x86_64"]
  package_type     = "Image"
  role             = aws_iam_role.yt_dlp_downloader.arn
  source_code_hash = trimprefix(data.aws_ecr_image.repo_image.id, "sha256:")

  environment {
    variables = {
      ENVIRONMENT              = local.app_version
      BUCKET_NAME              = aws_s3_bucket.main.bucket
      AWS_GRAPHQL_API_ENDPOINT = aws_appsync_graphql_api.main.uris.GRAPHQL
      AWS_GRAPHQL_API_KEY      = aws_appsync_api_key.main.key
    }
  }
}

data "aws_ecr_image" "repo_image" {
  repository_name = data.aws_ecr_repository.yt_dlp_downloader.name
  image_tag       = local.app_version
}

resource "aws_iam_role" "yt_dlp_downloader" {
  name = "yt-dlp-${local.app_version}"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "enqueue-download-inline-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Effect" : "Allow",
          "Action" : [
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:*",
            "s3-object-lambda:*"
          ],
          "Resource" : [
            "${aws_s3_bucket.main.arn}",
            "${aws_s3_bucket.main.arn}/*",
          ]
        }
      ]
    })
  }
}

resource "aws_s3_bucket" "main" {
  bucket        = "yt-dlp-${lower(data.aws_caller_identity.current.user_id)}"
  force_destroy = true
}

