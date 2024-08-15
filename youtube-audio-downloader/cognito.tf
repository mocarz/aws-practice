resource "aws_cognito_user_pool" "pool" {
  name = "yt-dlp-user-pool"
  deletion_protection = "INACTIVE"

  account_recovery_setting {
    recovery_mechanism {
      name = "verified_email"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  auto_verified_attributes = ["email"]
  
  schema {
    name = "email"
    attribute_data_type = "String"
    mutable = true
    required = true
  }

  schema {
    name = "given_name"
    attribute_data_type = "String"
    mutable = true
    required = true
  }

  schema {
    name = "family_name"
    attribute_data_type = "String"
    mutable = true
    required = true
  }

  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"]
  }

  username_attributes = ["email"]

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
}

resource "aws_cognito_user_pool_domain" "example" {
  domain       = "yt-dlp"
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool_client" "main" {
  name = "client"

  user_pool_id = aws_cognito_user_pool.pool.id

  callback_urls = ["https://example.com"]

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "phone"]
  supported_identity_providers         = ["COGNITO"]
}

# resource "random_uuid" "uuid" {
# }

resource "aws_cognito_user" "example" {
  user_pool_id = aws_cognito_user_pool.pool.id
  username     = "mocarskim2+terraform@gmail.com"

  attributes = {
    email      = "mocarskim2+terraform@gmail.com"
    given_name            = "Michal"
    family_name          = "Mocarski"
    email_verified = true
  }
}