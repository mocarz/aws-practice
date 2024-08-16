resource "aws_api_gateway_deployment" "dev" {
  rest_api_id = var.rest_api_id

  triggers = {
    redeployment = var.redeployment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.dev.id
  rest_api_id   = var.rest_api_id
  stage_name    = "dev"
  variables     = var.variables
}
