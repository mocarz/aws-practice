output "AWS_GRAPHQL_API_ENDPOINT" {
  value = aws_appsync_graphql_api.main.uris.GRAPHQL
}

output "AWS_GRAPHQL_API_ENDPOINT_REALTIME" {
  value = aws_appsync_graphql_api.main.uris.REALTIME
}

output "API_KEY" {
  value     = aws_appsync_api_key.main.key
  sensitive = true
}

output "CLOUDFRONT_ENDPOINT" {
  value = "https://${aws_cloudfront_distribution.main.domain_name}"
}
