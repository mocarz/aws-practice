module "lambda_role" {
  source = "./modules/lambdas/lambda_role"
}

module "weather_getter_lambda" {
  source        = "./modules/lambdas/weather_getter"
  weatherApiKey = var.weatherApiKey
  runtime       = var.runtime
  roleArn       = module.lambda_role.arn
}

module "weather_mapper_lambda" {
  source  = "./modules/lambdas/weather_mapper"
  runtime = var.runtime
  roleArn = module.lambda_role.arn
}

module "step_function" {
  source                     = "./modules/step_function"
  weather_getter_lambda_name = module.weather_getter_lambda.function_name
  weather_getter_lambda_arn  = module.weather_getter_lambda.lambdaArn
  weather_mapper_lambda_name = module.weather_mapper_lambda.function_name
  weather_mapper_lambda_arn  = module.weather_mapper_lambda.lambdaArn

  depends_on = [
    module.weather_getter_lambda,
    module.weather_mapper_lambda
  ]
}

module "api_gateway" {
  source = "./modules/api_gateway"
  region = var.region

  depends_on = [
    module.step_function
  ]
}

module "api_deployment" {
  source       = "./modules/api_deployment"
  rest_api_id  = module.api_gateway.rest_api_id
  redeployment = module.api_gateway.sha1
  variables = {
    arn = module.step_function.machine_arn
  }

  depends_on = [module.api_gateway]
}
