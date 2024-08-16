resource "aws_sfn_state_machine" "main" {
  name     = "Weather_state_machine"
  role_arn = aws_iam_role.step_functions_role.arn
  type     = "EXPRESS"

  definition = templatefile("${path.module}/state_machine.json", {
    start_at                   = var.weather_getter_lambda_name
    weather_getter_lambda_name = var.weather_getter_lambda_name
    weather_getter_lambda_arn  = var.weather_getter_lambda_arn
    weather_mapper_lambda_name = var.weather_mapper_lambda_name
    weather_mapper_lambda_arn  = var.weather_mapper_lambda_arn
  })
}
