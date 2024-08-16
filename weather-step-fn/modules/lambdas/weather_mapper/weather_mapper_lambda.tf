locals {
  archive_file = "build/weather_mapper_lambda_payload.zip"
  filename     = "weather_mapper"
}

data "archive_file" "archive" {
  type        = "zip"
  source_file = "${path.module}/src/${local.filename}.mjs"
  output_path = local.archive_file
}

resource "aws_lambda_function" "lambda" {
  role = var.roleArn

  filename      = local.archive_file
  function_name = local.filename
  handler       = "${local.filename}.lambda_handler"

  source_code_hash = data.archive_file.archive.output_base64sha256
  runtime          = var.runtime
}
