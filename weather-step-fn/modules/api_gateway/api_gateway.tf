resource "aws_api_gateway_rest_api" "main" {
  name        = "weather-api"
  description = "Weather API Gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  body = data.template_file.open_api.rendered
}


data "template_file" "open_api" {
  template = file("${path.module}/openapi.yaml")

  vars = {
    stepFunctionsArn = aws_iam_role.api_gateway_to_step_functions.arn
    region           = var.region
  }

}
