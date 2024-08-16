output "lambdaArn" {
  value = aws_lambda_function.lambda.arn
}

output "function_name" {
  value = local.filename
}