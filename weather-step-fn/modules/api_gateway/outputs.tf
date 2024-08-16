output "rest_api_id" {
  value = aws_api_gateway_rest_api.main.id
}

output "sha1" {
  value = sha1(jsonencode([
    aws_api_gateway_rest_api.main.body
  ]))
}
