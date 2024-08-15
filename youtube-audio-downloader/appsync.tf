resource "aws_appsync_graphql_api" "main" {
  name                = "yt-dlp-appsync-api"
  schema              = file("schema.graphql")
  authentication_type = "API_KEY"
  additional_authentication_provider {
    authentication_type = "AMAZON_COGNITO_USER_POOLS"

    user_pool_config {
      aws_region = data.aws_region.current.name
      user_pool_id = aws_cognito_user_pool.pool.id
    }
  }
}

resource "aws_appsync_api_key" "main" {
  api_id = aws_appsync_graphql_api.main.id
  #   expires = "2018-05-03T04:00:00Z"
}

resource "aws_appsync_datasource" "main" {
  api_id           = aws_appsync_graphql_api.main.id
  name             = "DynamoDB_${aws_dynamodb_table.download_status.name}"
  service_role_arn = aws_iam_role.appsync_service_role.arn
  type             = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name = aws_dynamodb_table.download_status.name
  }
}

resource "aws_appsync_datasource" "user_history" {
  api_id           = aws_appsync_graphql_api.main.id
  name             = "DynamoDB_${aws_dynamodb_table.user_history.name}"
  service_role_arn = aws_iam_role.appsync_service_role.arn
  type             = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name = aws_dynamodb_table.user_history.name
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["appsync.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "appsync_service_role" {
  name               = "appsync-service-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


data "aws_iam_policy_document" "dynamodb_full_access" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:*"]
    resources = [
      aws_dynamodb_table.download_status.arn,
      aws_dynamodb_table.user_history.arn
    ]
  }
}

resource "aws_iam_role_policy" "appsync_dynamodb_full_access" {
  name   = "appsync_dynamodb_full_access"
  role   = aws_iam_role.appsync_service_role.id
  policy = data.aws_iam_policy_document.dynamodb_full_access.json
}

locals {
  resolver_runtime_version = "1.0.0"
  resolver_runtime_name    = "APPSYNC_JS"
  resolver_type            = "UNIT"
}

# resource "aws_appsync_resolver" "listDownloadStatuses" {
#   api_id      = aws_appsync_graphql_api.main.id
#   data_source = aws_appsync_datasource.main.name
#   kind        = local.resolver_type
#   type        = "Query"
#   field       = "listDownloadStatuses"
#   code        = file("resolvers/list-download-statuses.js")

#   runtime {
#     name            = local.resolver_runtime_name
#     runtime_version = local.resolver_runtime_version
#   }
# }

resource "aws_appsync_resolver" "getDownloadStatus" {
  api_id      = aws_appsync_graphql_api.main.id
  data_source = aws_appsync_datasource.main.name
  kind        = local.resolver_type
  type        = "Query"
  field       = "getDownloadStatus"
  code        = file("resolvers/get-download-status.js")

  runtime {
    name            = local.resolver_runtime_name
    runtime_version = local.resolver_runtime_version
  }
}

# resource "aws_appsync_resolver" "createDownloadStatus" {
#   api_id      = aws_appsync_graphql_api.main.id
#   data_source = aws_appsync_datasource.main.name
#   kind        = local.resolver_type
#   type        = "Mutation"
#   field       = "createDownloadStatus"
#   code        = file("resolvers/create-download-status.js")

#   runtime {
#     name            = local.resolver_runtime_name
#     runtime_version = local.resolver_runtime_version
#   }
# }

resource "aws_appsync_resolver" "updateDownloadStatus" {
  api_id      = aws_appsync_graphql_api.main.id
  data_source = aws_appsync_datasource.main.name
  kind        = local.resolver_type
  type        = "Mutation"
  field       = "updateDownloadStatus"
  code        = file("resolvers/update-download-status.js")

  runtime {
    name            = local.resolver_runtime_name
    runtime_version = local.resolver_runtime_version
  }
}

resource "aws_appsync_resolver" "listMyDownloadHistory" {
  api_id      = aws_appsync_graphql_api.main.id
  data_source = aws_appsync_datasource.user_history.name
  kind        = local.resolver_type
  type        = "Query"
  field       = "listMyDownloadHistory"
  code        = file("resolvers/list-my-download-history.js")

  runtime {
    name            = local.resolver_runtime_name
    runtime_version = local.resolver_runtime_version
  }
}
