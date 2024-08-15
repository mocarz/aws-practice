resource "aws_appsync_datasource" "lambda" {
  api_id = aws_appsync_graphql_api.main.id
  name   = "yt_dlp_lambda_datasource"
  service_role_arn = aws_iam_role.appsync_lambda_datasource_service_role.arn
  type             = "AWS_LAMBDA"

  lambda_config {
    function_arn = aws_lambda_function.enqueue_download.arn
  }
}


data "aws_iam_policy_document" "appsync_lambda_datasource_service_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["appsync.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "appsync_lambda_datasource_service_role" {
  name               = "appsync-lambda-datasource-service-role"
  assume_role_policy = data.aws_iam_policy_document.appsync_lambda_datasource_service_role.json
}

data "aws_iam_policy_document" "invoke_lambda" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:invokeFunction"]
    resources = [aws_lambda_function.enqueue_download.arn]
  }
}

resource "aws_iam_role_policy" "appsync_invoke_lambda" {
  name   = "appsync_invoke_lambda"
  role   = aws_iam_role.appsync_lambda_datasource_service_role.id
  policy = data.aws_iam_policy_document.invoke_lambda.json
}



resource "aws_appsync_resolver" "enqueue_download" {
  api_id      = aws_appsync_graphql_api.main.id
  data_source = aws_appsync_datasource.lambda.name
  kind        = local.resolver_type
  type        = "Mutation"
  field       = "enqueueDownload"
  code        = file("resolvers/lambda_resolver.js")

  runtime {
    name            = local.resolver_runtime_name
    runtime_version = local.resolver_runtime_version
  }
}

locals {
  archve_path = "out/enqueue_download_payload.zip"
}

resource "aws_lambda_function" "enqueue_download" {
  function_name    = "enqueue-download"
  filename         = local.archve_path
  handler          = "index.lambda_handler"
  runtime          = "python3.11"
  role             = aws_iam_role.enqueue_download_lambda_role.arn
  source_code_hash = data.archive_file.enqueue_download.output_base64sha256


  environment {
    variables = {
      ENVIRONMENT         = local.app_version
      SQS_QUEUE_URL       = aws_sqs_queue.main.name
      DYNAMODB_DOWNLOAD_STATUS_TABLE_NAME = aws_dynamodb_table.download_status.name
      DYNAMODB_USER_HISTORY_TABLE_NAME = aws_dynamodb_table.user_history.name
    }
  }
}

data "archive_file" "enqueue_download" {
  type        = "zip"
  source_file = "lambda_functions/enqueueDownload/index.py"
  output_path = local.archve_path
}

resource "aws_iam_role" "enqueue_download_lambda_role" {
  name = "enqueue-download-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
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
          Action   = ["dynamodb:*"]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          "Action" : ["sqs:*"],
          "Effect" : "Allow",
          "Resource" : "*"
        },
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
        }
      ]
    })
  }

}

resource "aws_sqs_queue" "main" {
  name                       = "yt-dlp"
  visibility_timeout_seconds = 300
  
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead.arn
    maxReceiveCount     = 2
  })
}

resource "aws_lambda_event_source_mapping" "sqs_lambda" {
  event_source_arn = aws_sqs_queue.main.arn
  function_name    = aws_lambda_function.yt_dlp_downloader.arn

  depends_on = [aws_sqs_queue.main, aws_lambda_function.yt_dlp_downloader]
}

resource "aws_sqs_queue" "dead" {
  name                       = "yt-dlp-dead-letter"
  visibility_timeout_seconds = 300
}